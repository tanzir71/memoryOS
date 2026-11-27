import 'package:drift/drift.dart';
import '../capture/capture_dedupe.dart';
import '../data/database.dart';

class PersonCandidate {
  const PersonCandidate({
    this.phone,
    this.email,
    this.chatName,
    this.emailSenderName,
    this.app = '',
  });

  final String? phone;
  final String? email;
  final String? chatName;
  final String? emailSenderName;
  final String app;
}

/// Resolves signals to contacts and provisional people per `03-engines.md`.
/// Match order:
/// 1. Phone number (+880 normalised) -> contact
/// 2. Chat display name equal to a contact name
/// 3. Email sender name equal to a contact name
/// 4. Calendar attendee / email address equal to a contact email
/// No match: create provisional person keyed by (app, name) and merge it into
/// a contact when a handle matches later. Never merge two contacts automatically.
class PersonMatcher {
  PersonMatcher(this.db);

  final MemoryDatabase db;

  Future<int> upsertContact({
    required String displayName,
    required String lookupKey,
    List<String> phones = const [],
    List<String> emails = const [],
  }) async {
    final existing = await (db.select(db.person)
          ..where((t) => t.contactLookupKey.equals(lookupKey)))
        .getSingleOrNull();

    final personId = existing?.id ??
        await db.into(db.person).insert(
          PersonCompanion.insert(
            displayName: displayName.trim(),
            contactLookupKey: Value(lookupKey),
          ),
        );

    if (existing != null && existing.displayName != displayName.trim()) {
      await (db.update(db.person)..where((t) => t.id.equals(personId))).write(
        PersonCompanion(displayName: Value(displayName.trim())),
      );
    }

    for (final rawPhone in phones) {
      final norm = normalizePhoneNumber(rawPhone);
      if (norm.isEmpty) continue;
      await _attachHandleAndMergeProvisional(
        contactPersonId: personId,
        type: 'phone',
        value: norm,
        app: 'phone',
      );
    }

    for (final rawEmail in emails) {
      final norm = rawEmail.trim().toLowerCase();
      if (norm.isEmpty) continue;
      await _attachHandleAndMergeProvisional(
        contactPersonId: personId,
        type: 'email',
        value: norm,
        app: 'email',
      );
    }

    // Merge any provisional person with identical display name (never another contact).
    await _mergeProvisionalByName(personId, displayName.trim());

    return personId;
  }

  Future<int?> matchOrCreate(PersonCandidate candidate) async {
    // 1. Phone number match.
    if (candidate.phone != null && candidate.phone!.trim().isNotEmpty) {
      final norm = normalizePhoneNumber(candidate.phone!);
      final byPhone = await _findPersonByHandle('phone', norm);
      if (byPhone != null) return byPhone;
    }

    // 2. Chat display name equal to contact name (or existing chat_name handle).
    if (candidate.chatName != null && candidate.chatName!.trim().isNotEmpty) {
      final name = candidate.chatName!.trim();
      final byContactName = await _findContactByName(name);
      if (byContactName != null) {
        await _ensureHandle(byContactName, 'chat_name', _chatKey(candidate.app, name), candidate.app);
        return byContactName;
      }
      final byChatHandle = await _findPersonByHandle(
        'chat_name',
        _chatKey(candidate.app, name),
      );
      if (byChatHandle != null) return byChatHandle;
    }

    // 3. Email sender name equal to contact name.
    if (candidate.emailSenderName != null &&
        candidate.emailSenderName!.trim().isNotEmpty) {
      final byContactName = await _findContactByName(
        candidate.emailSenderName!.trim(),
      );
      if (byContactName != null) {
        if (candidate.email != null && candidate.email!.trim().isNotEmpty) {
          await _ensureHandle(
            byContactName,
            'email',
            candidate.email!.trim().toLowerCase(),
            'email',
          );
        }
        return byContactName;
      }
    }

    // 4. Email address match.
    if (candidate.email != null && candidate.email!.trim().isNotEmpty) {
      final normEmail = candidate.email!.trim().toLowerCase();
      final byEmail = await _findPersonByHandle('email', normEmail);
      if (byEmail != null) return byEmail;
    }

    // 5. Create provisional person keyed by (app, name) or phone/email.
    final fallbackName = [
      candidate.chatName,
      candidate.emailSenderName,
      candidate.email,
      candidate.phone,
    ].firstWhere((s) => s != null && s.trim().isNotEmpty, orElse: () => null);
    if (fallbackName == null) return null;

    final cleanName = fallbackName.trim();
    final provisionalId = await db.into(db.person).insert(
      PersonCompanion.insert(displayName: cleanName),
    );
    if (candidate.phone != null && candidate.phone!.trim().isNotEmpty) {
      await _ensureHandle(
        provisionalId,
        'phone',
        normalizePhoneNumber(candidate.phone!),
        'phone',
      );
    } else if (candidate.email != null && candidate.email!.trim().isNotEmpty) {
      await _ensureHandle(
        provisionalId,
        'email',
        candidate.email!.trim().toLowerCase(),
        'email',
      );
    } else {
      await _ensureHandle(
        provisionalId,
        'chat_name',
        _chatKey(candidate.app, cleanName),
        candidate.app,
      );
    }
    return provisionalId;
  }

  String _chatKey(String app, String name) =>
      '${app.toLowerCase()}::${name.trim().toLowerCase()}';

  Future<int?> _findPersonByHandle(String type, String value) async {
    final row = await (db.select(db.personHandle)
          ..where((t) => t.type.equals(type) & t.value.equals(value)))
        .getSingleOrNull();
    return row?.personId;
  }

  Future<int?> _findContactByName(String name) async {
    final lower = name.trim().toLowerCase();
    final contacts = await (db.select(db.person)
          ..where((t) => t.contactLookupKey.isNotNull()))
        .get();
    for (final c in contacts) {
      if (c.displayName.trim().toLowerCase() == lower) return c.id;
    }
    return null;
  }

  Future<void> _ensureHandle(
    int personId,
    String type,
    String value,
    String app,
  ) async {
    final existing = await (db.select(db.personHandle)
          ..where((t) => t.type.equals(type) & t.value.equals(value)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.personHandle).insert(
        PersonHandleCompanion.insert(
          personId: personId,
          type: type,
          value: value,
          app: Value(app),
        ),
      );
    }
  }

  Future<void> _attachHandleAndMergeProvisional({
    required int contactPersonId,
    required String type,
    required String value,
    required String app,
  }) async {
    final existingHandle = await (db.select(db.personHandle)
          ..where((t) => t.type.equals(type) & t.value.equals(value)))
        .getSingleOrNull();

    if (existingHandle == null) {
      await db.into(db.personHandle).insert(
        PersonHandleCompanion.insert(
          personId: contactPersonId,
          type: type,
          value: value,
          app: Value(app),
        ),
      );
      return;
    }

    if (existingHandle.personId == contactPersonId) return;

    final owner = await (db.select(db.person)
          ..where((t) => t.id.equals(existingHandle.personId)))
        .getSingleOrNull();
    // Never merge two contacts automatically.
    if (owner == null || owner.contactLookupKey != null) return;

    await _mergeProvisionalIntoContact(owner.id, contactPersonId);
  }

  Future<void> _mergeProvisionalByName(int contactId, String displayName) async {
    final lower = displayName.toLowerCase();
    final provisionals = await (db.select(db.person)
          ..where((t) => t.contactLookupKey.isNull()))
        .get();
    for (final p in provisionals) {
      if (p.displayName.trim().toLowerCase() == lower) {
        await _mergeProvisionalIntoContact(p.id, contactId);
      }
    }
  }

  Future<void> _mergeProvisionalIntoContact(
    int provisionalId,
    int contactId,
  ) async {
    await (db.update(db.signal)..where((t) => t.personId.equals(provisionalId)))
        .write(SignalCompanion(personId: Value(contactId)));
    await (db.update(db.memoryThread)
          ..where((t) => t.personId.equals(provisionalId)))
        .write(MemoryThreadCompanion(personId: Value(contactId)));
    await (db.update(db.personHandle)
          ..where((t) => t.personId.equals(provisionalId)))
        .write(PersonHandleCompanion(personId: Value(contactId)));
    await (db.delete(db.person)..where((t) => t.id.equals(provisionalId))).go();
  }
}
