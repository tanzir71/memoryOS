import 'dart:convert';
import 'package:drift/drift.dart';
import '../capture/capture_dedupe.dart';
import '../data/database.dart';
import 'day_summary_engine.dart';
import 'extractor.dart';
import 'intent_detector.dart';
import 'linker.dart';
import 'open_loop_engine.dart';
import 'person_matcher.dart';
import 'rules_loader.dart';
import 'triage.dart';

class RawPipelineEvent {
  const RawPipelineEvent({
    required this.source,
    this.pkg = '',
    this.channel = '',
    this.category = '',
    this.flags = 0,
    this.importance = 3,
    this.sbnKey,
    this.title = '',
    this.body = '',
    required this.occurredAt,
    this.endedAt,
    this.redacted = false,
    this.isConversation = false,
    this.isProgressTick = false,
    this.extras = const {},
  });

  final String source;
  final String pkg;
  final String channel;
  final String category;
  final int flags;
  final int importance;
  final String? sbnKey;
  final String title;
  final String body;
  final int occurredAt;
  final int? endedAt;
  final bool redacted;
  final bool isConversation;
  final bool isProgressTick;
  final Map<String, dynamic> extras;
}

/// Runs triage -> person -> extract -> intent -> link -> open loops on every
/// incoming event, persisting everything into `MemoryDatabase`.
class SignalPipeline {
  SignalPipeline({required this.db, required this.rules})
    : triage = TriageEngine(rules),
      personMatcher = PersonMatcher(db),
      extractor = ExtractionEngine(rules),
      intentDetector = IntentDetector(rules.intents),
      linker = ThreadLinker(db),
      openLoops = OpenLoopEngine(db),
      daySummary = DaySummaryEngine(db, rules);

  final MemoryDatabase db;
  final EngineRules rules;
  final TriageEngine triage;
  final PersonMatcher personMatcher;
  final ExtractionEngine extractor;
  final IntentDetector intentDetector;
  final ThreadLinker linker;
  final OpenLoopEngine openLoops;
  final DaySummaryEngine daySummary;

  Future<int> processEvent(RawPipelineEvent event) async {
    // 1. Triage.
    final appRule = event.pkg.isEmpty
        ? null
        : await (db.select(db.appRule)
              ..where((t) => t.pkg.equals(event.pkg)))
            .getSingleOrNull();
    final channelScoreRow = (event.pkg.isEmpty || event.channel.isEmpty)
        ? null
        : await (db.select(db.channelScore)
              ..where(
                (t) =>
                    t.pkg.equals(event.pkg) & t.channel.equals(event.channel),
              ))
            .getSingleOrNull();

    final triageRes = triage.evaluate(
      TriageInput(
        source: event.source,
        pkg: event.pkg,
        channel: event.channel,
        category: event.category,
        flags: event.flags,
        importance: event.importance,
        title: event.title,
        body: event.body,
        postedAt: event.occurredAt,
        removedAt: event.endedAt,
        redacted: event.redacted,
        isConversation: event.isConversation,
        isProgressTick: event.isProgressTick,
        userKeepOverride: appRule?.userSet == true ? appRule!.keepPolicy : null,
        channelScore: channelScoreRow?.score ?? 0,
      ),
    );

    // 2. Person match (only for kept personal/communication/calendar signals).
    int? personId;
    final enrichedExtras = Map<String, dynamic>.from(event.extras);
    if (triageRes.kept && _needsPersonMatch(triageRes.signalClass)) {
      personId = await _resolvePerson(event, triageRes.signalClass);
    }
    if (event.source == 'calendar' && event.extras['attendees'] is List) {
      final guestIds = <int>[];
      final guestNames = <String>[];
      for (final a in (event.extras['attendees'] as List)) {
        if (a is Map) {
          final email = a['email']?.toString();
          final name = a['name']?.toString();
          if (name != null && name.isNotEmpty) guestNames.add(name);
          final pid = await personMatcher.matchOrCreate(
            PersonCandidate(
              email: email,
              emailSenderName: name,
              app: 'calendar',
            ),
          );
          if (pid != null) guestIds.add(pid);
        }
      }
      enrichedExtras['guestPersonIds'] = guestIds;
      enrichedExtras['guestNames'] = guestNames;
    }

    // 3. Extract entities & structured fields.
    final extraction = triageRes.kept
        ? extractor.extract(
            pkg: event.pkg,
            senderAddress: event.title,
            title: triageRes.title,
            body: triageRes.body,
            signalClass: triageRes.signalClass,
          )
        : const ExtractionResult(
            matchedPack: null,
            kind: null,
            fields: {},
            entities: [],
            unparsedTransactional: false,
          );
    if (extraction.matchedPack != null) {
      enrichedExtras['matchedPack'] = extraction.matchedPack;
    }
    if (extraction.kind != null) {
      enrichedExtras['extractKind'] = extraction.kind;
    }
    enrichedExtras.addAll(extraction.fields);

    // 4. Insert signal row.
    final signalId = await db.into(db.signal).insert(
      SignalCompanion.insert(
        source: event.source,
        pkg: Value(event.pkg),
        kind: Value(
          extraction.kind ??
              (event.category.isNotEmpty ? event.category : event.source),
        ),
        sbnKey: Value(event.sbnKey),
        title: Value(triageRes.title),
        body: Value(triageRes.body),
        occurredAt: event.occurredAt,
        endedAt: Value(event.endedAt),
        personId: Value(personId),
        signalClass: Value(triageRes.signalClass),
        kept: Value(triageRes.kept),
        redacted: Value(triageRes.redacted),
        extrasJson: Value(jsonEncode(enrichedExtras)),
      ),
    );

    if (!triageRes.kept) return signalId;

    // Persist entities.
    for (final ent in extraction.entities) {
      final existing = await (db.select(db.entity)
            ..where(
              (t) =>
                  t.type.equals(ent.type) &
                  t.canonicalValue.equals(ent.canonicalValue),
            ))
          .getSingleOrNull();
      final entityId = existing?.id ??
          await db.into(db.entity).insert(
            EntityCompanion.insert(
              type: ent.type,
              canonicalValue: ent.canonicalValue,
              display: ent.display,
            ),
          );
      await db.into(db.signalEntity).insertOnConflictUpdate(
        SignalEntityCompanion.insert(
          signalId: signalId,
          entityId: entityId,
          role: Value(ent.role),
        ),
      );
    }

    // 5. Detect intents.
    final savedIntents = <(int, DetectedIntent, bool)>[];
    final refTime = DateTime.fromMillisecondsSinceEpoch(event.occurredAt);
    if (triageRes.signalClass == 'calendar') {
      final inviteTime = enrichedExtras['eventStartAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(
              enrichedExtras['eventStartAt'] as int,
            )
          : refTime;
      final det = intentDetector.detect(
        text: '${triageRes.title} ${triageRes.body}',
        referenceTime: refTime,
        isCalendarInvite: true,
        explicitDueAt: inviteTime,
      );
      final iid = await _saveIntent(signalId, det);
      savedIntents.add((iid, det, false));
    } else if (triageRes.signalClass == 'conversation' ||
        triageRes.signalClass == 'email') {
      final msgs = extractChatMessagesFromExtras(
        jsonEncode(enrichedExtras),
        fallbackSender: triageRes.title,
        fallbackText: triageRes.body,
        fallbackTime: event.occurredAt,
      );
      for (final m in msgs) {
        final det = intentDetector.detect(
          text: m.text,
          referenceTime: refTime,
          isSelf: m.isSelf,
        );
        final iid = await _saveIntent(signalId, det);
        savedIntents.add((iid, det, m.isSelf));
      }
    }

    // 6. Link into thread + process open loops.
    final sigRow = await (db.select(db.signal)
          ..where((t) => t.id.equals(signalId)))
        .getSingle();
    final linkRes = await linker.linkSignal(sig: sigRow, extraction: extraction);

    await openLoops.processSignal(
      sig: sigRow,
      threadId: linkRes.threadId,
      extraction: extraction,
      intents: savedIntents,
    );

    return signalId;
  }

  Future<int> _saveIntent(int signalId, DetectedIntent det) {
    return db.into(db.signalIntent).insert(
      SignalIntentCompanion.insert(
        signalId: signalId,
        type: det.type,
        content: det.text,
        dueAt: Value(det.dueAt?.millisecondsSinceEpoch),
        confidence: Value(det.confidence),
      ),
    );
  }

  bool _needsPersonMatch(String cls) =>
      cls == 'conversation' ||
      cls == 'call' ||
      cls == 'email' ||
      cls == 'calendar';

  Future<int?> _resolvePerson(RawPipelineEvent event, String cls) async {
    final phone = event.extras['number']?.toString() ??
        (event.source == 'sms' ? event.title : null);
    final email = event.extras['email']?.toString() ??
        event.extras['organizer']?.toString();
    if (cls == 'call') {
      return personMatcher.matchOrCreate(
        PersonCandidate(
          phone: phone,
          chatName: event.title,
          app: event.pkg.isNotEmpty ? event.pkg : 'phone',
        ),
      );
    }
    if (cls == 'email') {
      return personMatcher.matchOrCreate(
        PersonCandidate(
          email: email,
          emailSenderName: event.title,
          app: event.pkg,
        ),
      );
    }
    if (cls == 'calendar') {
      if (email != null && email.isNotEmpty) {
        return personMatcher.matchOrCreate(
          PersonCandidate(email: email, app: 'calendar'),
        );
      }
      return null;
    }
    return personMatcher.matchOrCreate(
      PersonCandidate(
        phone: phone,
        chatName: event.title,
        app: event.pkg.isNotEmpty ? event.pkg : event.source,
      ),
    );
  }
}
