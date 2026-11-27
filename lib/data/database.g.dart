// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SignalTable extends Signal with TableInfo<$SignalTable, SignalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _inboxIdMeta = const VerificationMeta(
    'inboxId',
  );
  @override
  late final GeneratedColumn<int> inboxId = GeneratedColumn<int>(
    'inbox_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pkgMeta = const VerificationMeta('pkg');
  @override
  late final GeneratedColumn<String> pkg = GeneratedColumn<String>(
    'pkg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sbnKeyMeta = const VerificationMeta('sbnKey');
  @override
  late final GeneratedColumn<String> sbnKey = GeneratedColumn<String>(
    'sbn_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signalClassMeta = const VerificationMeta(
    'signalClass',
  );
  @override
  late final GeneratedColumn<String> signalClass = GeneratedColumn<String>(
    'class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _keptMeta = const VerificationMeta('kept');
  @override
  late final GeneratedColumn<bool> kept = GeneratedColumn<bool>(
    'kept',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kept" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _redactedMeta = const VerificationMeta(
    'redacted',
  );
  @override
  late final GeneratedColumn<bool> redacted = GeneratedColumn<bool>(
    'redacted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("redacted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _extrasJsonMeta = const VerificationMeta(
    'extrasJson',
  );
  @override
  late final GeneratedColumn<String> extrasJson = GeneratedColumn<String>(
    'extras_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    inboxId,
    source,
    pkg,
    kind,
    sbnKey,
    title,
    body,
    occurredAt,
    endedAt,
    personId,
    signalClass,
    kept,
    redacted,
    extrasJson,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('inbox_id')) {
      context.handle(
        _inboxIdMeta,
        inboxId.isAcceptableOrUnknown(data['inbox_id']!, _inboxIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('pkg')) {
      context.handle(
        _pkgMeta,
        pkg.isAcceptableOrUnknown(data['pkg']!, _pkgMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('sbn_key')) {
      context.handle(
        _sbnKeyMeta,
        sbnKey.isAcceptableOrUnknown(data['sbn_key']!, _sbnKeyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('class')) {
      context.handle(
        _signalClassMeta,
        signalClass.isAcceptableOrUnknown(data['class']!, _signalClassMeta),
      );
    }
    if (data.containsKey('kept')) {
      context.handle(
        _keptMeta,
        kept.isAcceptableOrUnknown(data['kept']!, _keptMeta),
      );
    }
    if (data.containsKey('redacted')) {
      context.handle(
        _redactedMeta,
        redacted.isAcceptableOrUnknown(data['redacted']!, _redactedMeta),
      );
    }
    if (data.containsKey('extras_json')) {
      context.handle(
        _extrasJsonMeta,
        extrasJson.isAcceptableOrUnknown(data['extras_json']!, _extrasJsonMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      inboxId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inbox_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      pkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pkg'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sbnKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sbn_key'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      ),
      signalClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class'],
      )!,
      kept: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kept'],
      )!,
      redacted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}redacted'],
      )!,
      extrasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extras_json'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SignalTable createAlias(String alias) {
    return $SignalTable(attachedDatabase, alias);
  }
}

class SignalRow extends DataClass implements Insertable<SignalRow> {
  final int id;
  final int? inboxId;
  final String source;
  final String pkg;
  final String kind;
  final String? sbnKey;
  final String title;
  final String body;
  final int occurredAt;
  final int? endedAt;
  final int? personId;
  final String signalClass;
  final bool kept;
  final bool redacted;
  final String extrasJson;
  final int? deletedAt;
  const SignalRow({
    required this.id,
    this.inboxId,
    required this.source,
    required this.pkg,
    required this.kind,
    this.sbnKey,
    required this.title,
    required this.body,
    required this.occurredAt,
    this.endedAt,
    this.personId,
    required this.signalClass,
    required this.kept,
    required this.redacted,
    required this.extrasJson,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || inboxId != null) {
      map['inbox_id'] = Variable<int>(inboxId);
    }
    map['source'] = Variable<String>(source);
    map['pkg'] = Variable<String>(pkg);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || sbnKey != null) {
      map['sbn_key'] = Variable<String>(sbnKey);
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['occurred_at'] = Variable<int>(occurredAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<int>(personId);
    }
    map['class'] = Variable<String>(signalClass);
    map['kept'] = Variable<bool>(kept);
    map['redacted'] = Variable<bool>(redacted);
    map['extras_json'] = Variable<String>(extrasJson);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  SignalCompanion toCompanion(bool nullToAbsent) {
    return SignalCompanion(
      id: Value(id),
      inboxId: inboxId == null && nullToAbsent
          ? const Value.absent()
          : Value(inboxId),
      source: Value(source),
      pkg: Value(pkg),
      kind: Value(kind),
      sbnKey: sbnKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sbnKey),
      title: Value(title),
      body: Value(body),
      occurredAt: Value(occurredAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      signalClass: Value(signalClass),
      kept: Value(kept),
      redacted: Value(redacted),
      extrasJson: Value(extrasJson),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SignalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalRow(
      id: serializer.fromJson<int>(json['id']),
      inboxId: serializer.fromJson<int?>(json['inboxId']),
      source: serializer.fromJson<String>(json['source']),
      pkg: serializer.fromJson<String>(json['pkg']),
      kind: serializer.fromJson<String>(json['kind']),
      sbnKey: serializer.fromJson<String?>(json['sbnKey']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      personId: serializer.fromJson<int?>(json['personId']),
      signalClass: serializer.fromJson<String>(json['signalClass']),
      kept: serializer.fromJson<bool>(json['kept']),
      redacted: serializer.fromJson<bool>(json['redacted']),
      extrasJson: serializer.fromJson<String>(json['extrasJson']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'inboxId': serializer.toJson<int?>(inboxId),
      'source': serializer.toJson<String>(source),
      'pkg': serializer.toJson<String>(pkg),
      'kind': serializer.toJson<String>(kind),
      'sbnKey': serializer.toJson<String?>(sbnKey),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'personId': serializer.toJson<int?>(personId),
      'signalClass': serializer.toJson<String>(signalClass),
      'kept': serializer.toJson<bool>(kept),
      'redacted': serializer.toJson<bool>(redacted),
      'extrasJson': serializer.toJson<String>(extrasJson),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  SignalRow copyWith({
    int? id,
    Value<int?> inboxId = const Value.absent(),
    String? source,
    String? pkg,
    String? kind,
    Value<String?> sbnKey = const Value.absent(),
    String? title,
    String? body,
    int? occurredAt,
    Value<int?> endedAt = const Value.absent(),
    Value<int?> personId = const Value.absent(),
    String? signalClass,
    bool? kept,
    bool? redacted,
    String? extrasJson,
    Value<int?> deletedAt = const Value.absent(),
  }) => SignalRow(
    id: id ?? this.id,
    inboxId: inboxId.present ? inboxId.value : this.inboxId,
    source: source ?? this.source,
    pkg: pkg ?? this.pkg,
    kind: kind ?? this.kind,
    sbnKey: sbnKey.present ? sbnKey.value : this.sbnKey,
    title: title ?? this.title,
    body: body ?? this.body,
    occurredAt: occurredAt ?? this.occurredAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    personId: personId.present ? personId.value : this.personId,
    signalClass: signalClass ?? this.signalClass,
    kept: kept ?? this.kept,
    redacted: redacted ?? this.redacted,
    extrasJson: extrasJson ?? this.extrasJson,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SignalRow copyWithCompanion(SignalCompanion data) {
    return SignalRow(
      id: data.id.present ? data.id.value : this.id,
      inboxId: data.inboxId.present ? data.inboxId.value : this.inboxId,
      source: data.source.present ? data.source.value : this.source,
      pkg: data.pkg.present ? data.pkg.value : this.pkg,
      kind: data.kind.present ? data.kind.value : this.kind,
      sbnKey: data.sbnKey.present ? data.sbnKey.value : this.sbnKey,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      personId: data.personId.present ? data.personId.value : this.personId,
      signalClass: data.signalClass.present
          ? data.signalClass.value
          : this.signalClass,
      kept: data.kept.present ? data.kept.value : this.kept,
      redacted: data.redacted.present ? data.redacted.value : this.redacted,
      extrasJson: data.extrasJson.present
          ? data.extrasJson.value
          : this.extrasJson,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalRow(')
          ..write('id: $id, ')
          ..write('inboxId: $inboxId, ')
          ..write('source: $source, ')
          ..write('pkg: $pkg, ')
          ..write('kind: $kind, ')
          ..write('sbnKey: $sbnKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('personId: $personId, ')
          ..write('signalClass: $signalClass, ')
          ..write('kept: $kept, ')
          ..write('redacted: $redacted, ')
          ..write('extrasJson: $extrasJson, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    inboxId,
    source,
    pkg,
    kind,
    sbnKey,
    title,
    body,
    occurredAt,
    endedAt,
    personId,
    signalClass,
    kept,
    redacted,
    extrasJson,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalRow &&
          other.id == this.id &&
          other.inboxId == this.inboxId &&
          other.source == this.source &&
          other.pkg == this.pkg &&
          other.kind == this.kind &&
          other.sbnKey == this.sbnKey &&
          other.title == this.title &&
          other.body == this.body &&
          other.occurredAt == this.occurredAt &&
          other.endedAt == this.endedAt &&
          other.personId == this.personId &&
          other.signalClass == this.signalClass &&
          other.kept == this.kept &&
          other.redacted == this.redacted &&
          other.extrasJson == this.extrasJson &&
          other.deletedAt == this.deletedAt);
}

class SignalCompanion extends UpdateCompanion<SignalRow> {
  final Value<int> id;
  final Value<int?> inboxId;
  final Value<String> source;
  final Value<String> pkg;
  final Value<String> kind;
  final Value<String?> sbnKey;
  final Value<String> title;
  final Value<String> body;
  final Value<int> occurredAt;
  final Value<int?> endedAt;
  final Value<int?> personId;
  final Value<String> signalClass;
  final Value<bool> kept;
  final Value<bool> redacted;
  final Value<String> extrasJson;
  final Value<int?> deletedAt;
  const SignalCompanion({
    this.id = const Value.absent(),
    this.inboxId = const Value.absent(),
    this.source = const Value.absent(),
    this.pkg = const Value.absent(),
    this.kind = const Value.absent(),
    this.sbnKey = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.personId = const Value.absent(),
    this.signalClass = const Value.absent(),
    this.kept = const Value.absent(),
    this.redacted = const Value.absent(),
    this.extrasJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SignalCompanion.insert({
    this.id = const Value.absent(),
    this.inboxId = const Value.absent(),
    required String source,
    this.pkg = const Value.absent(),
    this.kind = const Value.absent(),
    this.sbnKey = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    required int occurredAt,
    this.endedAt = const Value.absent(),
    this.personId = const Value.absent(),
    this.signalClass = const Value.absent(),
    this.kept = const Value.absent(),
    this.redacted = const Value.absent(),
    this.extrasJson = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : source = Value(source),
       occurredAt = Value(occurredAt);
  static Insertable<SignalRow> custom({
    Expression<int>? id,
    Expression<int>? inboxId,
    Expression<String>? source,
    Expression<String>? pkg,
    Expression<String>? kind,
    Expression<String>? sbnKey,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? occurredAt,
    Expression<int>? endedAt,
    Expression<int>? personId,
    Expression<String>? signalClass,
    Expression<bool>? kept,
    Expression<bool>? redacted,
    Expression<String>? extrasJson,
    Expression<int>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (inboxId != null) 'inbox_id': inboxId,
      if (source != null) 'source': source,
      if (pkg != null) 'pkg': pkg,
      if (kind != null) 'kind': kind,
      if (sbnKey != null) 'sbn_key': sbnKey,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (personId != null) 'person_id': personId,
      if (signalClass != null) 'class': signalClass,
      if (kept != null) 'kept': kept,
      if (redacted != null) 'redacted': redacted,
      if (extrasJson != null) 'extras_json': extrasJson,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SignalCompanion copyWith({
    Value<int>? id,
    Value<int?>? inboxId,
    Value<String>? source,
    Value<String>? pkg,
    Value<String>? kind,
    Value<String?>? sbnKey,
    Value<String>? title,
    Value<String>? body,
    Value<int>? occurredAt,
    Value<int?>? endedAt,
    Value<int?>? personId,
    Value<String>? signalClass,
    Value<bool>? kept,
    Value<bool>? redacted,
    Value<String>? extrasJson,
    Value<int?>? deletedAt,
  }) {
    return SignalCompanion(
      id: id ?? this.id,
      inboxId: inboxId ?? this.inboxId,
      source: source ?? this.source,
      pkg: pkg ?? this.pkg,
      kind: kind ?? this.kind,
      sbnKey: sbnKey ?? this.sbnKey,
      title: title ?? this.title,
      body: body ?? this.body,
      occurredAt: occurredAt ?? this.occurredAt,
      endedAt: endedAt ?? this.endedAt,
      personId: personId ?? this.personId,
      signalClass: signalClass ?? this.signalClass,
      kept: kept ?? this.kept,
      redacted: redacted ?? this.redacted,
      extrasJson: extrasJson ?? this.extrasJson,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (inboxId.present) {
      map['inbox_id'] = Variable<int>(inboxId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (pkg.present) {
      map['pkg'] = Variable<String>(pkg.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sbnKey.present) {
      map['sbn_key'] = Variable<String>(sbnKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (signalClass.present) {
      map['class'] = Variable<String>(signalClass.value);
    }
    if (kept.present) {
      map['kept'] = Variable<bool>(kept.value);
    }
    if (redacted.present) {
      map['redacted'] = Variable<bool>(redacted.value);
    }
    if (extrasJson.present) {
      map['extras_json'] = Variable<String>(extrasJson.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalCompanion(')
          ..write('id: $id, ')
          ..write('inboxId: $inboxId, ')
          ..write('source: $source, ')
          ..write('pkg: $pkg, ')
          ..write('kind: $kind, ')
          ..write('sbnKey: $sbnKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('personId: $personId, ')
          ..write('signalClass: $signalClass, ')
          ..write('kept: $kept, ')
          ..write('redacted: $redacted, ')
          ..write('extrasJson: $extrasJson, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PersonTable extends Person with TableInfo<$PersonTable, PersonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactLookupKeyMeta = const VerificationMeta(
    'contactLookupKey',
  );
  @override
  late final GeneratedColumn<String> contactLookupKey = GeneratedColumn<String>(
    'contact_lookup_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    contactLookupKey,
    isMe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('contact_lookup_key')) {
      context.handle(
        _contactLookupKeyMeta,
        contactLookupKey.isAcceptableOrUnknown(
          data['contact_lookup_key']!,
          _contactLookupKeyMeta,
        ),
      );
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      contactLookupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_lookup_key'],
      ),
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
    );
  }

  @override
  $PersonTable createAlias(String alias) {
    return $PersonTable(attachedDatabase, alias);
  }
}

class PersonRow extends DataClass implements Insertable<PersonRow> {
  final int id;
  final String displayName;
  final String? contactLookupKey;
  final bool isMe;
  const PersonRow({
    required this.id,
    required this.displayName,
    this.contactLookupKey,
    required this.isMe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || contactLookupKey != null) {
      map['contact_lookup_key'] = Variable<String>(contactLookupKey);
    }
    map['is_me'] = Variable<bool>(isMe);
    return map;
  }

  PersonCompanion toCompanion(bool nullToAbsent) {
    return PersonCompanion(
      id: Value(id),
      displayName: Value(displayName),
      contactLookupKey: contactLookupKey == null && nullToAbsent
          ? const Value.absent()
          : Value(contactLookupKey),
      isMe: Value(isMe),
    );
  }

  factory PersonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonRow(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      contactLookupKey: serializer.fromJson<String?>(json['contactLookupKey']),
      isMe: serializer.fromJson<bool>(json['isMe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'contactLookupKey': serializer.toJson<String?>(contactLookupKey),
      'isMe': serializer.toJson<bool>(isMe),
    };
  }

  PersonRow copyWith({
    int? id,
    String? displayName,
    Value<String?> contactLookupKey = const Value.absent(),
    bool? isMe,
  }) => PersonRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    contactLookupKey: contactLookupKey.present
        ? contactLookupKey.value
        : this.contactLookupKey,
    isMe: isMe ?? this.isMe,
  );
  PersonRow copyWithCompanion(PersonCompanion data) {
    return PersonRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      contactLookupKey: data.contactLookupKey.present
          ? data.contactLookupKey.value
          : this.contactLookupKey,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('contactLookupKey: $contactLookupKey, ')
          ..write('isMe: $isMe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, contactLookupKey, isMe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.contactLookupKey == this.contactLookupKey &&
          other.isMe == this.isMe);
}

class PersonCompanion extends UpdateCompanion<PersonRow> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String?> contactLookupKey;
  final Value<bool> isMe;
  const PersonCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.contactLookupKey = const Value.absent(),
    this.isMe = const Value.absent(),
  });
  PersonCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    this.contactLookupKey = const Value.absent(),
    this.isMe = const Value.absent(),
  }) : displayName = Value(displayName);
  static Insertable<PersonRow> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? contactLookupKey,
    Expression<bool>? isMe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (contactLookupKey != null) 'contact_lookup_key': contactLookupKey,
      if (isMe != null) 'is_me': isMe,
    });
  }

  PersonCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String?>? contactLookupKey,
    Value<bool>? isMe,
  }) {
    return PersonCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      contactLookupKey: contactLookupKey ?? this.contactLookupKey,
      isMe: isMe ?? this.isMe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (contactLookupKey.present) {
      map['contact_lookup_key'] = Variable<String>(contactLookupKey.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('contactLookupKey: $contactLookupKey, ')
          ..write('isMe: $isMe')
          ..write(')'))
        .toString();
  }
}

class $PersonHandleTable extends PersonHandle
    with TableInfo<$PersonHandleTable, PersonHandleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonHandleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES person (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appMeta = const VerificationMeta('app');
  @override
  late final GeneratedColumn<String> app = GeneratedColumn<String>(
    'app',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, personId, type, value, app];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_handle';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonHandleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('app')) {
      context.handle(
        _appMeta,
        app.isAcceptableOrUnknown(data['app']!, _appMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, value},
  ];
  @override
  PersonHandleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonHandleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      app: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app'],
      )!,
    );
  }

  @override
  $PersonHandleTable createAlias(String alias) {
    return $PersonHandleTable(attachedDatabase, alias);
  }
}

class PersonHandleRow extends DataClass implements Insertable<PersonHandleRow> {
  final int id;
  final int personId;
  final String type;
  final String value;
  final String app;
  const PersonHandleRow({
    required this.id,
    required this.personId,
    required this.type,
    required this.value,
    required this.app,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['app'] = Variable<String>(app);
    return map;
  }

  PersonHandleCompanion toCompanion(bool nullToAbsent) {
    return PersonHandleCompanion(
      id: Value(id),
      personId: Value(personId),
      type: Value(type),
      value: Value(value),
      app: Value(app),
    );
  }

  factory PersonHandleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonHandleRow(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      app: serializer.fromJson<String>(json['app']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'app': serializer.toJson<String>(app),
    };
  }

  PersonHandleRow copyWith({
    int? id,
    int? personId,
    String? type,
    String? value,
    String? app,
  }) => PersonHandleRow(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    type: type ?? this.type,
    value: value ?? this.value,
    app: app ?? this.app,
  );
  PersonHandleRow copyWithCompanion(PersonHandleCompanion data) {
    return PersonHandleRow(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      app: data.app.present ? data.app.value : this.app,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonHandleRow(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('app: $app')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, personId, type, value, app);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonHandleRow &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.type == this.type &&
          other.value == this.value &&
          other.app == this.app);
}

class PersonHandleCompanion extends UpdateCompanion<PersonHandleRow> {
  final Value<int> id;
  final Value<int> personId;
  final Value<String> type;
  final Value<String> value;
  final Value<String> app;
  const PersonHandleCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.app = const Value.absent(),
  });
  PersonHandleCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    required String type,
    required String value,
    this.app = const Value.absent(),
  }) : personId = Value(personId),
       type = Value(type),
       value = Value(value);
  static Insertable<PersonHandleRow> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<String>? type,
    Expression<String>? value,
    Expression<String>? app,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (app != null) 'app': app,
    });
  }

  PersonHandleCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<String>? type,
    Value<String>? value,
    Value<String>? app,
  }) {
    return PersonHandleCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      type: type ?? this.type,
      value: value ?? this.value,
      app: app ?? this.app,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (app.present) {
      map['app'] = Variable<String>(app.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonHandleCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('app: $app')
          ..write(')'))
        .toString();
  }
}

class $EntityTable extends Entity with TableInfo<$EntityTable, EntityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalValueMeta = const VerificationMeta(
    'canonicalValue',
  );
  @override
  late final GeneratedColumn<String> canonicalValue = GeneratedColumn<String>(
    'canonical_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayMeta = const VerificationMeta(
    'display',
  );
  @override
  late final GeneratedColumn<String> display = GeneratedColumn<String>(
    'display',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, canonicalValue, display];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('canonical_value')) {
      context.handle(
        _canonicalValueMeta,
        canonicalValue.isAcceptableOrUnknown(
          data['canonical_value']!,
          _canonicalValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalValueMeta);
    }
    if (data.containsKey('display')) {
      context.handle(
        _displayMeta,
        display.isAcceptableOrUnknown(data['display']!, _displayMeta),
      );
    } else if (isInserting) {
      context.missing(_displayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, canonicalValue},
  ];
  @override
  EntityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      canonicalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_value'],
      )!,
      display: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display'],
      )!,
    );
  }

  @override
  $EntityTable createAlias(String alias) {
    return $EntityTable(attachedDatabase, alias);
  }
}

class EntityRow extends DataClass implements Insertable<EntityRow> {
  final int id;
  final String type;
  final String canonicalValue;
  final String display;
  const EntityRow({
    required this.id,
    required this.type,
    required this.canonicalValue,
    required this.display,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['canonical_value'] = Variable<String>(canonicalValue);
    map['display'] = Variable<String>(display);
    return map;
  }

  EntityCompanion toCompanion(bool nullToAbsent) {
    return EntityCompanion(
      id: Value(id),
      type: Value(type),
      canonicalValue: Value(canonicalValue),
      display: Value(display),
    );
  }

  factory EntityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      canonicalValue: serializer.fromJson<String>(json['canonicalValue']),
      display: serializer.fromJson<String>(json['display']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'canonicalValue': serializer.toJson<String>(canonicalValue),
      'display': serializer.toJson<String>(display),
    };
  }

  EntityRow copyWith({
    int? id,
    String? type,
    String? canonicalValue,
    String? display,
  }) => EntityRow(
    id: id ?? this.id,
    type: type ?? this.type,
    canonicalValue: canonicalValue ?? this.canonicalValue,
    display: display ?? this.display,
  );
  EntityRow copyWithCompanion(EntityCompanion data) {
    return EntityRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      canonicalValue: data.canonicalValue.present
          ? data.canonicalValue.value
          : this.canonicalValue,
      display: data.display.present ? data.display.value : this.display,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('canonicalValue: $canonicalValue, ')
          ..write('display: $display')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, canonicalValue, display);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.canonicalValue == this.canonicalValue &&
          other.display == this.display);
}

class EntityCompanion extends UpdateCompanion<EntityRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> canonicalValue;
  final Value<String> display;
  const EntityCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.canonicalValue = const Value.absent(),
    this.display = const Value.absent(),
  });
  EntityCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String canonicalValue,
    required String display,
  }) : type = Value(type),
       canonicalValue = Value(canonicalValue),
       display = Value(display);
  static Insertable<EntityRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? canonicalValue,
    Expression<String>? display,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (canonicalValue != null) 'canonical_value': canonicalValue,
      if (display != null) 'display': display,
    });
  }

  EntityCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? canonicalValue,
    Value<String>? display,
  }) {
    return EntityCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      canonicalValue: canonicalValue ?? this.canonicalValue,
      display: display ?? this.display,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (canonicalValue.present) {
      map['canonical_value'] = Variable<String>(canonicalValue.value);
    }
    if (display.present) {
      map['display'] = Variable<String>(display.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('canonicalValue: $canonicalValue, ')
          ..write('display: $display')
          ..write(')'))
        .toString();
  }
}

class $SignalEntityTable extends SignalEntity
    with TableInfo<$SignalEntityTable, SignalEntityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _signalIdMeta = const VerificationMeta(
    'signalId',
  );
  @override
  late final GeneratedColumn<int> signalId = GeneratedColumn<int>(
    'signal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entity (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mention'),
  );
  @override
  List<GeneratedColumn> get $columns => [signalId, entityId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signal_entity';
  @override
  VerificationContext validateIntegrity(
    Insertable<SignalEntityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('signal_id')) {
      context.handle(
        _signalIdMeta,
        signalId.isAcceptableOrUnknown(data['signal_id']!, _signalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signalIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {signalId, entityId, role};
  @override
  SignalEntityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignalEntityRow(
      signalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $SignalEntityTable createAlias(String alias) {
    return $SignalEntityTable(attachedDatabase, alias);
  }
}

class SignalEntityRow extends DataClass implements Insertable<SignalEntityRow> {
  final int signalId;
  final int entityId;
  final String role;
  const SignalEntityRow({
    required this.signalId,
    required this.entityId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['signal_id'] = Variable<int>(signalId);
    map['entity_id'] = Variable<int>(entityId);
    map['role'] = Variable<String>(role);
    return map;
  }

  SignalEntityCompanion toCompanion(bool nullToAbsent) {
    return SignalEntityCompanion(
      signalId: Value(signalId),
      entityId: Value(entityId),
      role: Value(role),
    );
  }

  factory SignalEntityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignalEntityRow(
      signalId: serializer.fromJson<int>(json['signalId']),
      entityId: serializer.fromJson<int>(json['entityId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'signalId': serializer.toJson<int>(signalId),
      'entityId': serializer.toJson<int>(entityId),
      'role': serializer.toJson<String>(role),
    };
  }

  SignalEntityRow copyWith({int? signalId, int? entityId, String? role}) =>
      SignalEntityRow(
        signalId: signalId ?? this.signalId,
        entityId: entityId ?? this.entityId,
        role: role ?? this.role,
      );
  SignalEntityRow copyWithCompanion(SignalEntityCompanion data) {
    return SignalEntityRow(
      signalId: data.signalId.present ? data.signalId.value : this.signalId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignalEntityRow(')
          ..write('signalId: $signalId, ')
          ..write('entityId: $entityId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(signalId, entityId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SignalEntityRow &&
          other.signalId == this.signalId &&
          other.entityId == this.entityId &&
          other.role == this.role);
}

class SignalEntityCompanion extends UpdateCompanion<SignalEntityRow> {
  final Value<int> signalId;
  final Value<int> entityId;
  final Value<String> role;
  final Value<int> rowid;
  const SignalEntityCompanion({
    this.signalId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignalEntityCompanion.insert({
    required int signalId,
    required int entityId,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : signalId = Value(signalId),
       entityId = Value(entityId);
  static Insertable<SignalEntityRow> custom({
    Expression<int>? signalId,
    Expression<int>? entityId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (signalId != null) 'signal_id': signalId,
      if (entityId != null) 'entity_id': entityId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignalEntityCompanion copyWith({
    Value<int>? signalId,
    Value<int>? entityId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return SignalEntityCompanion(
      signalId: signalId ?? this.signalId,
      entityId: entityId ?? this.entityId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (signalId.present) {
      map['signal_id'] = Variable<int>(signalId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalEntityCompanion(')
          ..write('signalId: $signalId, ')
          ..write('entityId: $entityId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SignalIntentTable extends SignalIntent
    with TableInfo<$SignalIntentTable, IntentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalIntentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _signalIdMeta = const VerificationMeta(
    'signalId',
  );
  @override
  late final GeneratedColumn<int> signalId = GeneratedColumn<int>(
    'signal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.4),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    signalId,
    type,
    content,
    dueAt,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intent';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('signal_id')) {
      context.handle(
        _signalIdMeta,
        signalId.isAcceptableOrUnknown(data['signal_id']!, _signalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signalIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      signalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $SignalIntentTable createAlias(String alias) {
    return $SignalIntentTable(attachedDatabase, alias);
  }
}

class IntentRow extends DataClass implements Insertable<IntentRow> {
  final int id;
  final int signalId;
  final String type;
  final String content;
  final int? dueAt;
  final double confidence;
  const IntentRow({
    required this.id,
    required this.signalId,
    required this.type,
    required this.content,
    this.dueAt,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['signal_id'] = Variable<int>(signalId);
    map['type'] = Variable<String>(type);
    map['text'] = Variable<String>(content);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  SignalIntentCompanion toCompanion(bool nullToAbsent) {
    return SignalIntentCompanion(
      id: Value(id),
      signalId: Value(signalId),
      type: Value(type),
      content: Value(content),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      confidence: Value(confidence),
    );
  }

  factory IntentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntentRow(
      id: serializer.fromJson<int>(json['id']),
      signalId: serializer.fromJson<int>(json['signalId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'signalId': serializer.toJson<int>(signalId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'dueAt': serializer.toJson<int?>(dueAt),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  IntentRow copyWith({
    int? id,
    int? signalId,
    String? type,
    String? content,
    Value<int?> dueAt = const Value.absent(),
    double? confidence,
  }) => IntentRow(
    id: id ?? this.id,
    signalId: signalId ?? this.signalId,
    type: type ?? this.type,
    content: content ?? this.content,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    confidence: confidence ?? this.confidence,
  );
  IntentRow copyWithCompanion(SignalIntentCompanion data) {
    return IntentRow(
      id: data.id.present ? data.id.value : this.id,
      signalId: data.signalId.present ? data.signalId.value : this.signalId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntentRow(')
          ..write('id: $id, ')
          ..write('signalId: $signalId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('dueAt: $dueAt, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, signalId, type, content, dueAt, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntentRow &&
          other.id == this.id &&
          other.signalId == this.signalId &&
          other.type == this.type &&
          other.content == this.content &&
          other.dueAt == this.dueAt &&
          other.confidence == this.confidence);
}

class SignalIntentCompanion extends UpdateCompanion<IntentRow> {
  final Value<int> id;
  final Value<int> signalId;
  final Value<String> type;
  final Value<String> content;
  final Value<int?> dueAt;
  final Value<double> confidence;
  const SignalIntentCompanion({
    this.id = const Value.absent(),
    this.signalId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  SignalIntentCompanion.insert({
    this.id = const Value.absent(),
    required int signalId,
    required String type,
    required String content,
    this.dueAt = const Value.absent(),
    this.confidence = const Value.absent(),
  }) : signalId = Value(signalId),
       type = Value(type),
       content = Value(content);
  static Insertable<IntentRow> custom({
    Expression<int>? id,
    Expression<int>? signalId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<int>? dueAt,
    Expression<double>? confidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (signalId != null) 'signal_id': signalId,
      if (type != null) 'type': type,
      if (content != null) 'text': content,
      if (dueAt != null) 'due_at': dueAt,
      if (confidence != null) 'confidence': confidence,
    });
  }

  SignalIntentCompanion copyWith({
    Value<int>? id,
    Value<int>? signalId,
    Value<String>? type,
    Value<String>? content,
    Value<int?>? dueAt,
    Value<double>? confidence,
  }) {
    return SignalIntentCompanion(
      id: id ?? this.id,
      signalId: signalId ?? this.signalId,
      type: type ?? this.type,
      content: content ?? this.content,
      dueAt: dueAt ?? this.dueAt,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (signalId.present) {
      map['signal_id'] = Variable<int>(signalId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalIntentCompanion(')
          ..write('id: $id, ')
          ..write('signalId: $signalId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('dueAt: $dueAt, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }
}

class $MemoryThreadTable extends MemoryThread
    with TableInfo<$MemoryThreadTable, ThreadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryThreadTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<int> lastAt = GeneratedColumn<int>(
    'last_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _userEditedMeta = const VerificationMeta(
    'userEdited',
  );
  @override
  late final GeneratedColumn<bool> userEdited = GeneratedColumn<bool>(
    'user_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    kind,
    personId,
    startedAt,
    lastAt,
    status,
    userEdited,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thread';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThreadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_at')) {
      context.handle(
        _lastAtMeta,
        lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('user_edited')) {
      context.handle(
        _userEditedMeta,
        userEdited.isAcceptableOrUnknown(data['user_edited']!, _userEditedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThreadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      lastAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      userEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_edited'],
      )!,
    );
  }

  @override
  $MemoryThreadTable createAlias(String alias) {
    return $MemoryThreadTable(attachedDatabase, alias);
  }
}

class ThreadRow extends DataClass implements Insertable<ThreadRow> {
  final int id;
  final String title;
  final String kind;
  final int? personId;
  final int startedAt;
  final int lastAt;
  final String status;
  final bool userEdited;
  const ThreadRow({
    required this.id,
    required this.title,
    required this.kind,
    this.personId,
    required this.startedAt,
    required this.lastAt,
    required this.status,
    required this.userEdited,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<int>(personId);
    }
    map['started_at'] = Variable<int>(startedAt);
    map['last_at'] = Variable<int>(lastAt);
    map['status'] = Variable<String>(status);
    map['user_edited'] = Variable<bool>(userEdited);
    return map;
  }

  MemoryThreadCompanion toCompanion(bool nullToAbsent) {
    return MemoryThreadCompanion(
      id: Value(id),
      title: Value(title),
      kind: Value(kind),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      startedAt: Value(startedAt),
      lastAt: Value(lastAt),
      status: Value(status),
      userEdited: Value(userEdited),
    );
  }

  factory ThreadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      personId: serializer.fromJson<int?>(json['personId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      lastAt: serializer.fromJson<int>(json['lastAt']),
      status: serializer.fromJson<String>(json['status']),
      userEdited: serializer.fromJson<bool>(json['userEdited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'personId': serializer.toJson<int?>(personId),
      'startedAt': serializer.toJson<int>(startedAt),
      'lastAt': serializer.toJson<int>(lastAt),
      'status': serializer.toJson<String>(status),
      'userEdited': serializer.toJson<bool>(userEdited),
    };
  }

  ThreadRow copyWith({
    int? id,
    String? title,
    String? kind,
    Value<int?> personId = const Value.absent(),
    int? startedAt,
    int? lastAt,
    String? status,
    bool? userEdited,
  }) => ThreadRow(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    personId: personId.present ? personId.value : this.personId,
    startedAt: startedAt ?? this.startedAt,
    lastAt: lastAt ?? this.lastAt,
    status: status ?? this.status,
    userEdited: userEdited ?? this.userEdited,
  );
  ThreadRow copyWithCompanion(MemoryThreadCompanion data) {
    return ThreadRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      personId: data.personId.present ? data.personId.value : this.personId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
      status: data.status.present ? data.status.value : this.status,
      userEdited: data.userEdited.present
          ? data.userEdited.value
          : this.userEdited,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThreadRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('personId: $personId, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastAt: $lastAt, ')
          ..write('status: $status, ')
          ..write('userEdited: $userEdited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    kind,
    personId,
    startedAt,
    lastAt,
    status,
    userEdited,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.personId == this.personId &&
          other.startedAt == this.startedAt &&
          other.lastAt == this.lastAt &&
          other.status == this.status &&
          other.userEdited == this.userEdited);
}

class MemoryThreadCompanion extends UpdateCompanion<ThreadRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<int?> personId;
  final Value<int> startedAt;
  final Value<int> lastAt;
  final Value<String> status;
  final Value<bool> userEdited;
  const MemoryThreadCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.personId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.status = const Value.absent(),
    this.userEdited = const Value.absent(),
  });
  MemoryThreadCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.kind = const Value.absent(),
    this.personId = const Value.absent(),
    required int startedAt,
    required int lastAt,
    this.status = const Value.absent(),
    this.userEdited = const Value.absent(),
  }) : title = Value(title),
       startedAt = Value(startedAt),
       lastAt = Value(lastAt);
  static Insertable<ThreadRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<int>? personId,
    Expression<int>? startedAt,
    Expression<int>? lastAt,
    Expression<String>? status,
    Expression<bool>? userEdited,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (personId != null) 'person_id': personId,
      if (startedAt != null) 'started_at': startedAt,
      if (lastAt != null) 'last_at': lastAt,
      if (status != null) 'status': status,
      if (userEdited != null) 'user_edited': userEdited,
    });
  }

  MemoryThreadCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? kind,
    Value<int?>? personId,
    Value<int>? startedAt,
    Value<int>? lastAt,
    Value<String>? status,
    Value<bool>? userEdited,
  }) {
    return MemoryThreadCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      personId: personId ?? this.personId,
      startedAt: startedAt ?? this.startedAt,
      lastAt: lastAt ?? this.lastAt,
      status: status ?? this.status,
      userEdited: userEdited ?? this.userEdited,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<int>(lastAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (userEdited.present) {
      map['user_edited'] = Variable<bool>(userEdited.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryThreadCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('personId: $personId, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastAt: $lastAt, ')
          ..write('status: $status, ')
          ..write('userEdited: $userEdited')
          ..write(')'))
        .toString();
  }
}

class $ThreadSignalTable extends ThreadSignal
    with TableInfo<$ThreadSignalTable, ThreadSignalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadSignalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES thread (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _signalIdMeta = const VerificationMeta(
    'signalId',
  );
  @override
  late final GeneratedColumn<int> signalId = GeneratedColumn<int>(
    'signal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [threadId, signalId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thread_signal';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThreadSignalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('signal_id')) {
      context.handle(
        _signalIdMeta,
        signalId.isAcceptableOrUnknown(data['signal_id']!, _signalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {threadId, signalId};
  @override
  ThreadSignalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThreadSignalRow(
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thread_id'],
      )!,
      signalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_id'],
      )!,
    );
  }

  @override
  $ThreadSignalTable createAlias(String alias) {
    return $ThreadSignalTable(attachedDatabase, alias);
  }
}

class ThreadSignalRow extends DataClass implements Insertable<ThreadSignalRow> {
  final int threadId;
  final int signalId;
  const ThreadSignalRow({required this.threadId, required this.signalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['thread_id'] = Variable<int>(threadId);
    map['signal_id'] = Variable<int>(signalId);
    return map;
  }

  ThreadSignalCompanion toCompanion(bool nullToAbsent) {
    return ThreadSignalCompanion(
      threadId: Value(threadId),
      signalId: Value(signalId),
    );
  }

  factory ThreadSignalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThreadSignalRow(
      threadId: serializer.fromJson<int>(json['threadId']),
      signalId: serializer.fromJson<int>(json['signalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'threadId': serializer.toJson<int>(threadId),
      'signalId': serializer.toJson<int>(signalId),
    };
  }

  ThreadSignalRow copyWith({int? threadId, int? signalId}) => ThreadSignalRow(
    threadId: threadId ?? this.threadId,
    signalId: signalId ?? this.signalId,
  );
  ThreadSignalRow copyWithCompanion(ThreadSignalCompanion data) {
    return ThreadSignalRow(
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      signalId: data.signalId.present ? data.signalId.value : this.signalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThreadSignalRow(')
          ..write('threadId: $threadId, ')
          ..write('signalId: $signalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(threadId, signalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThreadSignalRow &&
          other.threadId == this.threadId &&
          other.signalId == this.signalId);
}

class ThreadSignalCompanion extends UpdateCompanion<ThreadSignalRow> {
  final Value<int> threadId;
  final Value<int> signalId;
  final Value<int> rowid;
  const ThreadSignalCompanion({
    this.threadId = const Value.absent(),
    this.signalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThreadSignalCompanion.insert({
    required int threadId,
    required int signalId,
    this.rowid = const Value.absent(),
  }) : threadId = Value(threadId),
       signalId = Value(signalId);
  static Insertable<ThreadSignalRow> custom({
    Expression<int>? threadId,
    Expression<int>? signalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (threadId != null) 'thread_id': threadId,
      if (signalId != null) 'signal_id': signalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThreadSignalCompanion copyWith({
    Value<int>? threadId,
    Value<int>? signalId,
    Value<int>? rowid,
  }) {
    return ThreadSignalCompanion(
      threadId: threadId ?? this.threadId,
      signalId: signalId ?? this.signalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (signalId.present) {
      map['signal_id'] = Variable<int>(signalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadSignalCompanion(')
          ..write('threadId: $threadId, ')
          ..write('signalId: $signalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SignalLinkTable extends SignalLink
    with TableInfo<$SignalLinkTable, LinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignalLinkTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES thread (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _signalIdMeta = const VerificationMeta(
    'signalId',
  );
  @override
  late final GeneratedColumn<int> signalId = GeneratedColumn<int>(
    'signal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _reasonsJsonMeta = const VerificationMeta(
    'reasonsJson',
  );
  @override
  late final GeneratedColumn<String> reasonsJson = GeneratedColumn<String>(
    'reasons_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('linked'),
  );
  static const VerificationMeta _decidedByMeta = const VerificationMeta(
    'decidedBy',
  );
  @override
  late final GeneratedColumn<String> decidedBy = GeneratedColumn<String>(
    'decided_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rule'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    signalId,
    reasonsJson,
    score,
    state,
    decidedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'link';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('signal_id')) {
      context.handle(
        _signalIdMeta,
        signalId.isAcceptableOrUnknown(data['signal_id']!, _signalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signalIdMeta);
    }
    if (data.containsKey('reasons_json')) {
      context.handle(
        _reasonsJsonMeta,
        reasonsJson.isAcceptableOrUnknown(
          data['reasons_json']!,
          _reasonsJsonMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('decided_by')) {
      context.handle(
        _decidedByMeta,
        decidedBy.isAcceptableOrUnknown(data['decided_by']!, _decidedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thread_id'],
      )!,
      signalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_id'],
      )!,
      reasonsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reasons_json'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      decidedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decided_by'],
      )!,
    );
  }

  @override
  $SignalLinkTable createAlias(String alias) {
    return $SignalLinkTable(attachedDatabase, alias);
  }
}

class LinkRow extends DataClass implements Insertable<LinkRow> {
  final int id;
  final int threadId;
  final int signalId;
  final String reasonsJson;
  final double score;
  final String state;
  final String decidedBy;
  const LinkRow({
    required this.id,
    required this.threadId,
    required this.signalId,
    required this.reasonsJson,
    required this.score,
    required this.state,
    required this.decidedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thread_id'] = Variable<int>(threadId);
    map['signal_id'] = Variable<int>(signalId);
    map['reasons_json'] = Variable<String>(reasonsJson);
    map['score'] = Variable<double>(score);
    map['state'] = Variable<String>(state);
    map['decided_by'] = Variable<String>(decidedBy);
    return map;
  }

  SignalLinkCompanion toCompanion(bool nullToAbsent) {
    return SignalLinkCompanion(
      id: Value(id),
      threadId: Value(threadId),
      signalId: Value(signalId),
      reasonsJson: Value(reasonsJson),
      score: Value(score),
      state: Value(state),
      decidedBy: Value(decidedBy),
    );
  }

  factory LinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkRow(
      id: serializer.fromJson<int>(json['id']),
      threadId: serializer.fromJson<int>(json['threadId']),
      signalId: serializer.fromJson<int>(json['signalId']),
      reasonsJson: serializer.fromJson<String>(json['reasonsJson']),
      score: serializer.fromJson<double>(json['score']),
      state: serializer.fromJson<String>(json['state']),
      decidedBy: serializer.fromJson<String>(json['decidedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'threadId': serializer.toJson<int>(threadId),
      'signalId': serializer.toJson<int>(signalId),
      'reasonsJson': serializer.toJson<String>(reasonsJson),
      'score': serializer.toJson<double>(score),
      'state': serializer.toJson<String>(state),
      'decidedBy': serializer.toJson<String>(decidedBy),
    };
  }

  LinkRow copyWith({
    int? id,
    int? threadId,
    int? signalId,
    String? reasonsJson,
    double? score,
    String? state,
    String? decidedBy,
  }) => LinkRow(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    signalId: signalId ?? this.signalId,
    reasonsJson: reasonsJson ?? this.reasonsJson,
    score: score ?? this.score,
    state: state ?? this.state,
    decidedBy: decidedBy ?? this.decidedBy,
  );
  LinkRow copyWithCompanion(SignalLinkCompanion data) {
    return LinkRow(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      signalId: data.signalId.present ? data.signalId.value : this.signalId,
      reasonsJson: data.reasonsJson.present
          ? data.reasonsJson.value
          : this.reasonsJson,
      score: data.score.present ? data.score.value : this.score,
      state: data.state.present ? data.state.value : this.state,
      decidedBy: data.decidedBy.present ? data.decidedBy.value : this.decidedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkRow(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('signalId: $signalId, ')
          ..write('reasonsJson: $reasonsJson, ')
          ..write('score: $score, ')
          ..write('state: $state, ')
          ..write('decidedBy: $decidedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, threadId, signalId, reasonsJson, score, state, decidedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkRow &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.signalId == this.signalId &&
          other.reasonsJson == this.reasonsJson &&
          other.score == this.score &&
          other.state == this.state &&
          other.decidedBy == this.decidedBy);
}

class SignalLinkCompanion extends UpdateCompanion<LinkRow> {
  final Value<int> id;
  final Value<int> threadId;
  final Value<int> signalId;
  final Value<String> reasonsJson;
  final Value<double> score;
  final Value<String> state;
  final Value<String> decidedBy;
  const SignalLinkCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.signalId = const Value.absent(),
    this.reasonsJson = const Value.absent(),
    this.score = const Value.absent(),
    this.state = const Value.absent(),
    this.decidedBy = const Value.absent(),
  });
  SignalLinkCompanion.insert({
    this.id = const Value.absent(),
    required int threadId,
    required int signalId,
    this.reasonsJson = const Value.absent(),
    this.score = const Value.absent(),
    this.state = const Value.absent(),
    this.decidedBy = const Value.absent(),
  }) : threadId = Value(threadId),
       signalId = Value(signalId);
  static Insertable<LinkRow> custom({
    Expression<int>? id,
    Expression<int>? threadId,
    Expression<int>? signalId,
    Expression<String>? reasonsJson,
    Expression<double>? score,
    Expression<String>? state,
    Expression<String>? decidedBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (signalId != null) 'signal_id': signalId,
      if (reasonsJson != null) 'reasons_json': reasonsJson,
      if (score != null) 'score': score,
      if (state != null) 'state': state,
      if (decidedBy != null) 'decided_by': decidedBy,
    });
  }

  SignalLinkCompanion copyWith({
    Value<int>? id,
    Value<int>? threadId,
    Value<int>? signalId,
    Value<String>? reasonsJson,
    Value<double>? score,
    Value<String>? state,
    Value<String>? decidedBy,
  }) {
    return SignalLinkCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      signalId: signalId ?? this.signalId,
      reasonsJson: reasonsJson ?? this.reasonsJson,
      score: score ?? this.score,
      state: state ?? this.state,
      decidedBy: decidedBy ?? this.decidedBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (signalId.present) {
      map['signal_id'] = Variable<int>(signalId.value);
    }
    if (reasonsJson.present) {
      map['reasons_json'] = Variable<String>(reasonsJson.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (decidedBy.present) {
      map['decided_by'] = Variable<String>(decidedBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignalLinkCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('signalId: $signalId, ')
          ..write('reasonsJson: $reasonsJson, ')
          ..write('score: $score, ')
          ..write('state: $state, ')
          ..write('decidedBy: $decidedBy')
          ..write(')'))
        .toString();
  }
}

class $OpenLoopTable extends OpenLoop
    with TableInfo<$OpenLoopTable, OpenLoopRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpenLoopTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<int> threadId = GeneratedColumn<int>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES thread (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _intentIdMeta = const VerificationMeta(
    'intentId',
  );
  @override
  late final GeneratedColumn<int> intentId = GeneratedColumn<int>(
    'intent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    intentId,
    owner,
    title,
    dueAt,
    state,
    closedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'open_loop';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpenLoopRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('intent_id')) {
      context.handle(
        _intentIdMeta,
        intentId.isAcceptableOrUnknown(data['intent_id']!, _intentIdMeta),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpenLoopRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpenLoopRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}thread_id'],
      )!,
      intentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intent_id'],
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by'],
      ),
    );
  }

  @override
  $OpenLoopTable createAlias(String alias) {
    return $OpenLoopTable(attachedDatabase, alias);
  }
}

class OpenLoopRow extends DataClass implements Insertable<OpenLoopRow> {
  final int id;
  final int threadId;
  final int? intentId;
  final String owner;
  final String title;
  final int? dueAt;
  final String state;
  final String? closedBy;
  const OpenLoopRow({
    required this.id,
    required this.threadId,
    this.intentId,
    required this.owner,
    required this.title,
    this.dueAt,
    required this.state,
    this.closedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['thread_id'] = Variable<int>(threadId);
    if (!nullToAbsent || intentId != null) {
      map['intent_id'] = Variable<int>(intentId);
    }
    map['owner'] = Variable<String>(owner);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    return map;
  }

  OpenLoopCompanion toCompanion(bool nullToAbsent) {
    return OpenLoopCompanion(
      id: Value(id),
      threadId: Value(threadId),
      intentId: intentId == null && nullToAbsent
          ? const Value.absent()
          : Value(intentId),
      owner: Value(owner),
      title: Value(title),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      state: Value(state),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
    );
  }

  factory OpenLoopRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpenLoopRow(
      id: serializer.fromJson<int>(json['id']),
      threadId: serializer.fromJson<int>(json['threadId']),
      intentId: serializer.fromJson<int?>(json['intentId']),
      owner: serializer.fromJson<String>(json['owner']),
      title: serializer.fromJson<String>(json['title']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      state: serializer.fromJson<String>(json['state']),
      closedBy: serializer.fromJson<String?>(json['closedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'threadId': serializer.toJson<int>(threadId),
      'intentId': serializer.toJson<int?>(intentId),
      'owner': serializer.toJson<String>(owner),
      'title': serializer.toJson<String>(title),
      'dueAt': serializer.toJson<int?>(dueAt),
      'state': serializer.toJson<String>(state),
      'closedBy': serializer.toJson<String?>(closedBy),
    };
  }

  OpenLoopRow copyWith({
    int? id,
    int? threadId,
    Value<int?> intentId = const Value.absent(),
    String? owner,
    String? title,
    Value<int?> dueAt = const Value.absent(),
    String? state,
    Value<String?> closedBy = const Value.absent(),
  }) => OpenLoopRow(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    intentId: intentId.present ? intentId.value : this.intentId,
    owner: owner ?? this.owner,
    title: title ?? this.title,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    state: state ?? this.state,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
  );
  OpenLoopRow copyWithCompanion(OpenLoopCompanion data) {
    return OpenLoopRow(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      intentId: data.intentId.present ? data.intentId.value : this.intentId,
      owner: data.owner.present ? data.owner.value : this.owner,
      title: data.title.present ? data.title.value : this.title,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      state: data.state.present ? data.state.value : this.state,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpenLoopRow(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('intentId: $intentId, ')
          ..write('owner: $owner, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('state: $state, ')
          ..write('closedBy: $closedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, threadId, intentId, owner, title, dueAt, state, closedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenLoopRow &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.intentId == this.intentId &&
          other.owner == this.owner &&
          other.title == this.title &&
          other.dueAt == this.dueAt &&
          other.state == this.state &&
          other.closedBy == this.closedBy);
}

class OpenLoopCompanion extends UpdateCompanion<OpenLoopRow> {
  final Value<int> id;
  final Value<int> threadId;
  final Value<int?> intentId;
  final Value<String> owner;
  final Value<String> title;
  final Value<int?> dueAt;
  final Value<String> state;
  final Value<String?> closedBy;
  const OpenLoopCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.intentId = const Value.absent(),
    this.owner = const Value.absent(),
    this.title = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.state = const Value.absent(),
    this.closedBy = const Value.absent(),
  });
  OpenLoopCompanion.insert({
    this.id = const Value.absent(),
    required int threadId,
    this.intentId = const Value.absent(),
    required String owner,
    required String title,
    this.dueAt = const Value.absent(),
    this.state = const Value.absent(),
    this.closedBy = const Value.absent(),
  }) : threadId = Value(threadId),
       owner = Value(owner),
       title = Value(title);
  static Insertable<OpenLoopRow> custom({
    Expression<int>? id,
    Expression<int>? threadId,
    Expression<int>? intentId,
    Expression<String>? owner,
    Expression<String>? title,
    Expression<int>? dueAt,
    Expression<String>? state,
    Expression<String>? closedBy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (intentId != null) 'intent_id': intentId,
      if (owner != null) 'owner': owner,
      if (title != null) 'title': title,
      if (dueAt != null) 'due_at': dueAt,
      if (state != null) 'state': state,
      if (closedBy != null) 'closed_by': closedBy,
    });
  }

  OpenLoopCompanion copyWith({
    Value<int>? id,
    Value<int>? threadId,
    Value<int?>? intentId,
    Value<String>? owner,
    Value<String>? title,
    Value<int?>? dueAt,
    Value<String>? state,
    Value<String?>? closedBy,
  }) {
    return OpenLoopCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      intentId: intentId ?? this.intentId,
      owner: owner ?? this.owner,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      state: state ?? this.state,
      closedBy: closedBy ?? this.closedBy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<int>(threadId.value);
    }
    if (intentId.present) {
      map['intent_id'] = Variable<int>(intentId.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpenLoopCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('intentId: $intentId, ')
          ..write('owner: $owner, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('state: $state, ')
          ..write('closedBy: $closedBy')
          ..write(')'))
        .toString();
  }
}

class $SeriesTable extends Series with TableInfo<$SeriesTable, SeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartKeyMeta = const VerificationMeta(
    'counterpartKey',
  );
  @override
  late final GeneratedColumn<String> counterpartKey = GeneratedColumn<String>(
    'counterpart_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleJsonMeta = const VerificationMeta(
    'cycleJson',
  );
  @override
  late final GeneratedColumn<String> cycleJson = GeneratedColumn<String>(
    'cycle_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _certaintyMeta = const VerificationMeta(
    'certainty',
  );
  @override
  late final GeneratedColumn<String> certainty = GeneratedColumn<String>(
    'certainty',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guess'),
  );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<double> strength = GeneratedColumn<double>(
    'strength',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('undecided'),
  );
  static const VerificationMeta _trackingMeta = const VerificationMeta(
    'tracking',
  );
  @override
  late final GeneratedColumn<bool> tracking = GeneratedColumn<bool>(
    'tracking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tracking" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastEventAtMeta = const VerificationMeta(
    'lastEventAt',
  );
  @override
  late final GeneratedColumn<int> lastEventAt = GeneratedColumn<int>(
    'last_event_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextFromMeta = const VerificationMeta(
    'nextFrom',
  );
  @override
  late final GeneratedColumn<int> nextFrom = GeneratedColumn<int>(
    'next_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextToMeta = const VerificationMeta('nextTo');
  @override
  late final GeneratedColumn<int> nextTo = GeneratedColumn<int>(
    'next_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expected'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    family,
    kind,
    counterpartKey,
    title,
    cycleJson,
    certainty,
    strength,
    decision,
    tracking,
    lastEventAt,
    nextFrom,
    nextTo,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    } else if (isInserting) {
      context.missing(_familyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('counterpart_key')) {
      context.handle(
        _counterpartKeyMeta,
        counterpartKey.isAcceptableOrUnknown(
          data['counterpart_key']!,
          _counterpartKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_counterpartKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cycle_json')) {
      context.handle(
        _cycleJsonMeta,
        cycleJson.isAcceptableOrUnknown(data['cycle_json']!, _cycleJsonMeta),
      );
    }
    if (data.containsKey('certainty')) {
      context.handle(
        _certaintyMeta,
        certainty.isAcceptableOrUnknown(data['certainty']!, _certaintyMeta),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    }
    if (data.containsKey('tracking')) {
      context.handle(
        _trackingMeta,
        tracking.isAcceptableOrUnknown(data['tracking']!, _trackingMeta),
      );
    }
    if (data.containsKey('last_event_at')) {
      context.handle(
        _lastEventAtMeta,
        lastEventAt.isAcceptableOrUnknown(
          data['last_event_at']!,
          _lastEventAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastEventAtMeta);
    }
    if (data.containsKey('next_from')) {
      context.handle(
        _nextFromMeta,
        nextFrom.isAcceptableOrUnknown(data['next_from']!, _nextFromMeta),
      );
    }
    if (data.containsKey('next_to')) {
      context.handle(
        _nextToMeta,
        nextTo.isAcceptableOrUnknown(data['next_to']!, _nextToMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      counterpartKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterpart_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      cycleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_json'],
      )!,
      certainty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certainty'],
      )!,
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strength'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      tracking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tracking'],
      )!,
      lastEventAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_event_at'],
      )!,
      nextFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_from'],
      ),
      nextTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_to'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $SeriesTable createAlias(String alias) {
    return $SeriesTable(attachedDatabase, alias);
  }
}

class SeriesRow extends DataClass implements Insertable<SeriesRow> {
  final int id;
  final String family;
  final String kind;
  final String counterpartKey;
  final String title;
  final String cycleJson;
  final String certainty;
  final double strength;
  final String decision;
  final bool tracking;
  final int lastEventAt;
  final int? nextFrom;
  final int? nextTo;
  final String state;
  const SeriesRow({
    required this.id,
    required this.family,
    required this.kind,
    required this.counterpartKey,
    required this.title,
    required this.cycleJson,
    required this.certainty,
    required this.strength,
    required this.decision,
    required this.tracking,
    required this.lastEventAt,
    this.nextFrom,
    this.nextTo,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['family'] = Variable<String>(family);
    map['kind'] = Variable<String>(kind);
    map['counterpart_key'] = Variable<String>(counterpartKey);
    map['title'] = Variable<String>(title);
    map['cycle_json'] = Variable<String>(cycleJson);
    map['certainty'] = Variable<String>(certainty);
    map['strength'] = Variable<double>(strength);
    map['decision'] = Variable<String>(decision);
    map['tracking'] = Variable<bool>(tracking);
    map['last_event_at'] = Variable<int>(lastEventAt);
    if (!nullToAbsent || nextFrom != null) {
      map['next_from'] = Variable<int>(nextFrom);
    }
    if (!nullToAbsent || nextTo != null) {
      map['next_to'] = Variable<int>(nextTo);
    }
    map['state'] = Variable<String>(state);
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(
      id: Value(id),
      family: Value(family),
      kind: Value(kind),
      counterpartKey: Value(counterpartKey),
      title: Value(title),
      cycleJson: Value(cycleJson),
      certainty: Value(certainty),
      strength: Value(strength),
      decision: Value(decision),
      tracking: Value(tracking),
      lastEventAt: Value(lastEventAt),
      nextFrom: nextFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFrom),
      nextTo: nextTo == null && nullToAbsent
          ? const Value.absent()
          : Value(nextTo),
      state: Value(state),
    );
  }

  factory SeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesRow(
      id: serializer.fromJson<int>(json['id']),
      family: serializer.fromJson<String>(json['family']),
      kind: serializer.fromJson<String>(json['kind']),
      counterpartKey: serializer.fromJson<String>(json['counterpartKey']),
      title: serializer.fromJson<String>(json['title']),
      cycleJson: serializer.fromJson<String>(json['cycleJson']),
      certainty: serializer.fromJson<String>(json['certainty']),
      strength: serializer.fromJson<double>(json['strength']),
      decision: serializer.fromJson<String>(json['decision']),
      tracking: serializer.fromJson<bool>(json['tracking']),
      lastEventAt: serializer.fromJson<int>(json['lastEventAt']),
      nextFrom: serializer.fromJson<int?>(json['nextFrom']),
      nextTo: serializer.fromJson<int?>(json['nextTo']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'family': serializer.toJson<String>(family),
      'kind': serializer.toJson<String>(kind),
      'counterpartKey': serializer.toJson<String>(counterpartKey),
      'title': serializer.toJson<String>(title),
      'cycleJson': serializer.toJson<String>(cycleJson),
      'certainty': serializer.toJson<String>(certainty),
      'strength': serializer.toJson<double>(strength),
      'decision': serializer.toJson<String>(decision),
      'tracking': serializer.toJson<bool>(tracking),
      'lastEventAt': serializer.toJson<int>(lastEventAt),
      'nextFrom': serializer.toJson<int?>(nextFrom),
      'nextTo': serializer.toJson<int?>(nextTo),
      'state': serializer.toJson<String>(state),
    };
  }

  SeriesRow copyWith({
    int? id,
    String? family,
    String? kind,
    String? counterpartKey,
    String? title,
    String? cycleJson,
    String? certainty,
    double? strength,
    String? decision,
    bool? tracking,
    int? lastEventAt,
    Value<int?> nextFrom = const Value.absent(),
    Value<int?> nextTo = const Value.absent(),
    String? state,
  }) => SeriesRow(
    id: id ?? this.id,
    family: family ?? this.family,
    kind: kind ?? this.kind,
    counterpartKey: counterpartKey ?? this.counterpartKey,
    title: title ?? this.title,
    cycleJson: cycleJson ?? this.cycleJson,
    certainty: certainty ?? this.certainty,
    strength: strength ?? this.strength,
    decision: decision ?? this.decision,
    tracking: tracking ?? this.tracking,
    lastEventAt: lastEventAt ?? this.lastEventAt,
    nextFrom: nextFrom.present ? nextFrom.value : this.nextFrom,
    nextTo: nextTo.present ? nextTo.value : this.nextTo,
    state: state ?? this.state,
  );
  SeriesRow copyWithCompanion(SeriesCompanion data) {
    return SeriesRow(
      id: data.id.present ? data.id.value : this.id,
      family: data.family.present ? data.family.value : this.family,
      kind: data.kind.present ? data.kind.value : this.kind,
      counterpartKey: data.counterpartKey.present
          ? data.counterpartKey.value
          : this.counterpartKey,
      title: data.title.present ? data.title.value : this.title,
      cycleJson: data.cycleJson.present ? data.cycleJson.value : this.cycleJson,
      certainty: data.certainty.present ? data.certainty.value : this.certainty,
      strength: data.strength.present ? data.strength.value : this.strength,
      decision: data.decision.present ? data.decision.value : this.decision,
      tracking: data.tracking.present ? data.tracking.value : this.tracking,
      lastEventAt: data.lastEventAt.present
          ? data.lastEventAt.value
          : this.lastEventAt,
      nextFrom: data.nextFrom.present ? data.nextFrom.value : this.nextFrom,
      nextTo: data.nextTo.present ? data.nextTo.value : this.nextTo,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRow(')
          ..write('id: $id, ')
          ..write('family: $family, ')
          ..write('kind: $kind, ')
          ..write('counterpartKey: $counterpartKey, ')
          ..write('title: $title, ')
          ..write('cycleJson: $cycleJson, ')
          ..write('certainty: $certainty, ')
          ..write('strength: $strength, ')
          ..write('decision: $decision, ')
          ..write('tracking: $tracking, ')
          ..write('lastEventAt: $lastEventAt, ')
          ..write('nextFrom: $nextFrom, ')
          ..write('nextTo: $nextTo, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    family,
    kind,
    counterpartKey,
    title,
    cycleJson,
    certainty,
    strength,
    decision,
    tracking,
    lastEventAt,
    nextFrom,
    nextTo,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesRow &&
          other.id == this.id &&
          other.family == this.family &&
          other.kind == this.kind &&
          other.counterpartKey == this.counterpartKey &&
          other.title == this.title &&
          other.cycleJson == this.cycleJson &&
          other.certainty == this.certainty &&
          other.strength == this.strength &&
          other.decision == this.decision &&
          other.tracking == this.tracking &&
          other.lastEventAt == this.lastEventAt &&
          other.nextFrom == this.nextFrom &&
          other.nextTo == this.nextTo &&
          other.state == this.state);
}

class SeriesCompanion extends UpdateCompanion<SeriesRow> {
  final Value<int> id;
  final Value<String> family;
  final Value<String> kind;
  final Value<String> counterpartKey;
  final Value<String> title;
  final Value<String> cycleJson;
  final Value<String> certainty;
  final Value<double> strength;
  final Value<String> decision;
  final Value<bool> tracking;
  final Value<int> lastEventAt;
  final Value<int?> nextFrom;
  final Value<int?> nextTo;
  final Value<String> state;
  const SeriesCompanion({
    this.id = const Value.absent(),
    this.family = const Value.absent(),
    this.kind = const Value.absent(),
    this.counterpartKey = const Value.absent(),
    this.title = const Value.absent(),
    this.cycleJson = const Value.absent(),
    this.certainty = const Value.absent(),
    this.strength = const Value.absent(),
    this.decision = const Value.absent(),
    this.tracking = const Value.absent(),
    this.lastEventAt = const Value.absent(),
    this.nextFrom = const Value.absent(),
    this.nextTo = const Value.absent(),
    this.state = const Value.absent(),
  });
  SeriesCompanion.insert({
    this.id = const Value.absent(),
    required String family,
    required String kind,
    required String counterpartKey,
    required String title,
    this.cycleJson = const Value.absent(),
    this.certainty = const Value.absent(),
    this.strength = const Value.absent(),
    this.decision = const Value.absent(),
    this.tracking = const Value.absent(),
    required int lastEventAt,
    this.nextFrom = const Value.absent(),
    this.nextTo = const Value.absent(),
    this.state = const Value.absent(),
  }) : family = Value(family),
       kind = Value(kind),
       counterpartKey = Value(counterpartKey),
       title = Value(title),
       lastEventAt = Value(lastEventAt);
  static Insertable<SeriesRow> custom({
    Expression<int>? id,
    Expression<String>? family,
    Expression<String>? kind,
    Expression<String>? counterpartKey,
    Expression<String>? title,
    Expression<String>? cycleJson,
    Expression<String>? certainty,
    Expression<double>? strength,
    Expression<String>? decision,
    Expression<bool>? tracking,
    Expression<int>? lastEventAt,
    Expression<int>? nextFrom,
    Expression<int>? nextTo,
    Expression<String>? state,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (family != null) 'family': family,
      if (kind != null) 'kind': kind,
      if (counterpartKey != null) 'counterpart_key': counterpartKey,
      if (title != null) 'title': title,
      if (cycleJson != null) 'cycle_json': cycleJson,
      if (certainty != null) 'certainty': certainty,
      if (strength != null) 'strength': strength,
      if (decision != null) 'decision': decision,
      if (tracking != null) 'tracking': tracking,
      if (lastEventAt != null) 'last_event_at': lastEventAt,
      if (nextFrom != null) 'next_from': nextFrom,
      if (nextTo != null) 'next_to': nextTo,
      if (state != null) 'state': state,
    });
  }

  SeriesCompanion copyWith({
    Value<int>? id,
    Value<String>? family,
    Value<String>? kind,
    Value<String>? counterpartKey,
    Value<String>? title,
    Value<String>? cycleJson,
    Value<String>? certainty,
    Value<double>? strength,
    Value<String>? decision,
    Value<bool>? tracking,
    Value<int>? lastEventAt,
    Value<int?>? nextFrom,
    Value<int?>? nextTo,
    Value<String>? state,
  }) {
    return SeriesCompanion(
      id: id ?? this.id,
      family: family ?? this.family,
      kind: kind ?? this.kind,
      counterpartKey: counterpartKey ?? this.counterpartKey,
      title: title ?? this.title,
      cycleJson: cycleJson ?? this.cycleJson,
      certainty: certainty ?? this.certainty,
      strength: strength ?? this.strength,
      decision: decision ?? this.decision,
      tracking: tracking ?? this.tracking,
      lastEventAt: lastEventAt ?? this.lastEventAt,
      nextFrom: nextFrom ?? this.nextFrom,
      nextTo: nextTo ?? this.nextTo,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (counterpartKey.present) {
      map['counterpart_key'] = Variable<String>(counterpartKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cycleJson.present) {
      map['cycle_json'] = Variable<String>(cycleJson.value);
    }
    if (certainty.present) {
      map['certainty'] = Variable<String>(certainty.value);
    }
    if (strength.present) {
      map['strength'] = Variable<double>(strength.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (tracking.present) {
      map['tracking'] = Variable<bool>(tracking.value);
    }
    if (lastEventAt.present) {
      map['last_event_at'] = Variable<int>(lastEventAt.value);
    }
    if (nextFrom.present) {
      map['next_from'] = Variable<int>(nextFrom.value);
    }
    if (nextTo.present) {
      map['next_to'] = Variable<int>(nextTo.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('id: $id, ')
          ..write('family: $family, ')
          ..write('kind: $kind, ')
          ..write('counterpartKey: $counterpartKey, ')
          ..write('title: $title, ')
          ..write('cycleJson: $cycleJson, ')
          ..write('certainty: $certainty, ')
          ..write('strength: $strength, ')
          ..write('decision: $decision, ')
          ..write('tracking: $tracking, ')
          ..write('lastEventAt: $lastEventAt, ')
          ..write('nextFrom: $nextFrom, ')
          ..write('nextTo: $nextTo, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

class $SeriesSignalTable extends SeriesSignal
    with TableInfo<$SeriesSignalTable, SeriesSignalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesSignalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _signalIdMeta = const VerificationMeta(
    'signalId',
  );
  @override
  late final GeneratedColumn<int> signalId = GeneratedColumn<int>(
    'signal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES signal (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, signalId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_signal';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesSignalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('signal_id')) {
      context.handle(
        _signalIdMeta,
        signalId.isAcceptableOrUnknown(data['signal_id']!, _signalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_signalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, signalId};
  @override
  SeriesSignalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesSignalRow(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      signalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signal_id'],
      )!,
    );
  }

  @override
  $SeriesSignalTable createAlias(String alias) {
    return $SeriesSignalTable(attachedDatabase, alias);
  }
}

class SeriesSignalRow extends DataClass implements Insertable<SeriesSignalRow> {
  final int seriesId;
  final int signalId;
  const SeriesSignalRow({required this.seriesId, required this.signalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['signal_id'] = Variable<int>(signalId);
    return map;
  }

  SeriesSignalCompanion toCompanion(bool nullToAbsent) {
    return SeriesSignalCompanion(
      seriesId: Value(seriesId),
      signalId: Value(signalId),
    );
  }

  factory SeriesSignalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesSignalRow(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      signalId: serializer.fromJson<int>(json['signalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'signalId': serializer.toJson<int>(signalId),
    };
  }

  SeriesSignalRow copyWith({int? seriesId, int? signalId}) => SeriesSignalRow(
    seriesId: seriesId ?? this.seriesId,
    signalId: signalId ?? this.signalId,
  );
  SeriesSignalRow copyWithCompanion(SeriesSignalCompanion data) {
    return SeriesSignalRow(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      signalId: data.signalId.present ? data.signalId.value : this.signalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSignalRow(')
          ..write('seriesId: $seriesId, ')
          ..write('signalId: $signalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, signalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesSignalRow &&
          other.seriesId == this.seriesId &&
          other.signalId == this.signalId);
}

class SeriesSignalCompanion extends UpdateCompanion<SeriesSignalRow> {
  final Value<int> seriesId;
  final Value<int> signalId;
  final Value<int> rowid;
  const SeriesSignalCompanion({
    this.seriesId = const Value.absent(),
    this.signalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesSignalCompanion.insert({
    required int seriesId,
    required int signalId,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       signalId = Value(signalId);
  static Insertable<SeriesSignalRow> custom({
    Expression<int>? seriesId,
    Expression<int>? signalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (signalId != null) 'signal_id': signalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesSignalCompanion copyWith({
    Value<int>? seriesId,
    Value<int>? signalId,
    Value<int>? rowid,
  }) {
    return SeriesSignalCompanion(
      seriesId: seriesId ?? this.seriesId,
      signalId: signalId ?? this.signalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (signalId.present) {
      map['signal_id'] = Variable<int>(signalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSignalCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('signalId: $signalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedbackTable extends Feedback
    with TableInfo<$FeedbackTable, FeedbackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, targetType, targetId, action, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedbackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedbackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedbackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $FeedbackTable createAlias(String alias) {
    return $FeedbackTable(attachedDatabase, alias);
  }
}

class FeedbackRow extends DataClass implements Insertable<FeedbackRow> {
  final int id;
  final String targetType;
  final int targetId;
  final String action;
  final int at;
  const FeedbackRow({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.action,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<int>(targetId);
    map['action'] = Variable<String>(action);
    map['at'] = Variable<int>(at);
    return map;
  }

  FeedbackCompanion toCompanion(bool nullToAbsent) {
    return FeedbackCompanion(
      id: Value(id),
      targetType: Value(targetType),
      targetId: Value(targetId),
      action: Value(action),
      at: Value(at),
    );
  }

  factory FeedbackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedbackRow(
      id: serializer.fromJson<int>(json['id']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<int>(json['targetId']),
      action: serializer.fromJson<String>(json['action']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<int>(targetId),
      'action': serializer.toJson<String>(action),
      'at': serializer.toJson<int>(at),
    };
  }

  FeedbackRow copyWith({
    int? id,
    String? targetType,
    int? targetId,
    String? action,
    int? at,
  }) => FeedbackRow(
    id: id ?? this.id,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    action: action ?? this.action,
    at: at ?? this.at,
  );
  FeedbackRow copyWithCompanion(FeedbackCompanion data) {
    return FeedbackRow(
      id: data.id.present ? data.id.value : this.id,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      action: data.action.present ? data.action.value : this.action,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackRow(')
          ..write('id: $id, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('action: $action, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetType, targetId, action, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackRow &&
          other.id == this.id &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.action == this.action &&
          other.at == this.at);
}

class FeedbackCompanion extends UpdateCompanion<FeedbackRow> {
  final Value<int> id;
  final Value<String> targetType;
  final Value<int> targetId;
  final Value<String> action;
  final Value<int> at;
  const FeedbackCompanion({
    this.id = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.action = const Value.absent(),
    this.at = const Value.absent(),
  });
  FeedbackCompanion.insert({
    this.id = const Value.absent(),
    required String targetType,
    required int targetId,
    required String action,
    required int at,
  }) : targetType = Value(targetType),
       targetId = Value(targetId),
       action = Value(action),
       at = Value(at);
  static Insertable<FeedbackRow> custom({
    Expression<int>? id,
    Expression<String>? targetType,
    Expression<int>? targetId,
    Expression<String>? action,
    Expression<int>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (action != null) 'action': action,
      if (at != null) 'at': at,
    });
  }

  FeedbackCompanion copyWith({
    Value<int>? id,
    Value<String>? targetType,
    Value<int>? targetId,
    Value<String>? action,
    Value<int>? at,
  }) {
    return FeedbackCompanion(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      action: action ?? this.action,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackCompanion(')
          ..write('id: $id, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('action: $action, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $SuppressRuleTable extends SuppressRule
    with TableInfo<$SuppressRuleTable, SuppressRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppressRuleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartKeyMeta = const VerificationMeta(
    'counterpartKey',
  );
  @override
  late final GeneratedColumn<String> counterpartKey = GeneratedColumn<String>(
    'counterpart_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user_drop'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    family,
    kind,
    counterpartKey,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppress_rule';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuppressRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    } else if (isInserting) {
      context.missing(_familyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('counterpart_key')) {
      context.handle(
        _counterpartKeyMeta,
        counterpartKey.isAcceptableOrUnknown(
          data['counterpart_key']!,
          _counterpartKeyMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuppressRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuppressRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      counterpartKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterpart_key'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $SuppressRuleTable createAlias(String alias) {
    return $SuppressRuleTable(attachedDatabase, alias);
  }
}

class SuppressRuleRow extends DataClass implements Insertable<SuppressRuleRow> {
  final int id;
  final String family;
  final String kind;
  final String? counterpartKey;
  final String reason;
  const SuppressRuleRow({
    required this.id,
    required this.family,
    required this.kind,
    this.counterpartKey,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['family'] = Variable<String>(family);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || counterpartKey != null) {
      map['counterpart_key'] = Variable<String>(counterpartKey);
    }
    map['reason'] = Variable<String>(reason);
    return map;
  }

  SuppressRuleCompanion toCompanion(bool nullToAbsent) {
    return SuppressRuleCompanion(
      id: Value(id),
      family: Value(family),
      kind: Value(kind),
      counterpartKey: counterpartKey == null && nullToAbsent
          ? const Value.absent()
          : Value(counterpartKey),
      reason: Value(reason),
    );
  }

  factory SuppressRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuppressRuleRow(
      id: serializer.fromJson<int>(json['id']),
      family: serializer.fromJson<String>(json['family']),
      kind: serializer.fromJson<String>(json['kind']),
      counterpartKey: serializer.fromJson<String?>(json['counterpartKey']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'family': serializer.toJson<String>(family),
      'kind': serializer.toJson<String>(kind),
      'counterpartKey': serializer.toJson<String?>(counterpartKey),
      'reason': serializer.toJson<String>(reason),
    };
  }

  SuppressRuleRow copyWith({
    int? id,
    String? family,
    String? kind,
    Value<String?> counterpartKey = const Value.absent(),
    String? reason,
  }) => SuppressRuleRow(
    id: id ?? this.id,
    family: family ?? this.family,
    kind: kind ?? this.kind,
    counterpartKey: counterpartKey.present
        ? counterpartKey.value
        : this.counterpartKey,
    reason: reason ?? this.reason,
  );
  SuppressRuleRow copyWithCompanion(SuppressRuleCompanion data) {
    return SuppressRuleRow(
      id: data.id.present ? data.id.value : this.id,
      family: data.family.present ? data.family.value : this.family,
      kind: data.kind.present ? data.kind.value : this.kind,
      counterpartKey: data.counterpartKey.present
          ? data.counterpartKey.value
          : this.counterpartKey,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuppressRuleRow(')
          ..write('id: $id, ')
          ..write('family: $family, ')
          ..write('kind: $kind, ')
          ..write('counterpartKey: $counterpartKey, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, family, kind, counterpartKey, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuppressRuleRow &&
          other.id == this.id &&
          other.family == this.family &&
          other.kind == this.kind &&
          other.counterpartKey == this.counterpartKey &&
          other.reason == this.reason);
}

class SuppressRuleCompanion extends UpdateCompanion<SuppressRuleRow> {
  final Value<int> id;
  final Value<String> family;
  final Value<String> kind;
  final Value<String?> counterpartKey;
  final Value<String> reason;
  const SuppressRuleCompanion({
    this.id = const Value.absent(),
    this.family = const Value.absent(),
    this.kind = const Value.absent(),
    this.counterpartKey = const Value.absent(),
    this.reason = const Value.absent(),
  });
  SuppressRuleCompanion.insert({
    this.id = const Value.absent(),
    required String family,
    required String kind,
    this.counterpartKey = const Value.absent(),
    this.reason = const Value.absent(),
  }) : family = Value(family),
       kind = Value(kind);
  static Insertable<SuppressRuleRow> custom({
    Expression<int>? id,
    Expression<String>? family,
    Expression<String>? kind,
    Expression<String>? counterpartKey,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (family != null) 'family': family,
      if (kind != null) 'kind': kind,
      if (counterpartKey != null) 'counterpart_key': counterpartKey,
      if (reason != null) 'reason': reason,
    });
  }

  SuppressRuleCompanion copyWith({
    Value<int>? id,
    Value<String>? family,
    Value<String>? kind,
    Value<String?>? counterpartKey,
    Value<String>? reason,
  }) {
    return SuppressRuleCompanion(
      id: id ?? this.id,
      family: family ?? this.family,
      kind: kind ?? this.kind,
      counterpartKey: counterpartKey ?? this.counterpartKey,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (counterpartKey.present) {
      map['counterpart_key'] = Variable<String>(counterpartKey.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppressRuleCompanion(')
          ..write('id: $id, ')
          ..write('family: $family, ')
          ..write('kind: $kind, ')
          ..write('counterpartKey: $counterpartKey, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

class $AppRuleTable extends AppRule with TableInfo<$AppRuleTable, AppRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppRuleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pkgMeta = const VerificationMeta('pkg');
  @override
  late final GeneratedColumn<String> pkg = GeneratedColumn<String>(
    'pkg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appClassMeta = const VerificationMeta(
    'appClass',
  );
  @override
  late final GeneratedColumn<String> appClass = GeneratedColumn<String>(
    'class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _keepPolicyMeta = const VerificationMeta(
    'keepPolicy',
  );
  @override
  late final GeneratedColumn<String> keepPolicy = GeneratedColumn<String>(
    'keep_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _userSetMeta = const VerificationMeta(
    'userSet',
  );
  @override
  late final GeneratedColumn<bool> userSet = GeneratedColumn<bool>(
    'user_set',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_set" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [pkg, appClass, keepPolicy, userSet];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_rule';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pkg')) {
      context.handle(
        _pkgMeta,
        pkg.isAcceptableOrUnknown(data['pkg']!, _pkgMeta),
      );
    } else if (isInserting) {
      context.missing(_pkgMeta);
    }
    if (data.containsKey('class')) {
      context.handle(
        _appClassMeta,
        appClass.isAcceptableOrUnknown(data['class']!, _appClassMeta),
      );
    }
    if (data.containsKey('keep_policy')) {
      context.handle(
        _keepPolicyMeta,
        keepPolicy.isAcceptableOrUnknown(data['keep_policy']!, _keepPolicyMeta),
      );
    }
    if (data.containsKey('user_set')) {
      context.handle(
        _userSetMeta,
        userSet.isAcceptableOrUnknown(data['user_set']!, _userSetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pkg};
  @override
  AppRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppRuleRow(
      pkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pkg'],
      )!,
      appClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class'],
      )!,
      keepPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keep_policy'],
      )!,
      userSet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_set'],
      )!,
    );
  }

  @override
  $AppRuleTable createAlias(String alias) {
    return $AppRuleTable(attachedDatabase, alias);
  }
}

class AppRuleRow extends DataClass implements Insertable<AppRuleRow> {
  final String pkg;
  final String appClass;
  final String keepPolicy;
  final bool userSet;
  const AppRuleRow({
    required this.pkg,
    required this.appClass,
    required this.keepPolicy,
    required this.userSet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pkg'] = Variable<String>(pkg);
    map['class'] = Variable<String>(appClass);
    map['keep_policy'] = Variable<String>(keepPolicy);
    map['user_set'] = Variable<bool>(userSet);
    return map;
  }

  AppRuleCompanion toCompanion(bool nullToAbsent) {
    return AppRuleCompanion(
      pkg: Value(pkg),
      appClass: Value(appClass),
      keepPolicy: Value(keepPolicy),
      userSet: Value(userSet),
    );
  }

  factory AppRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppRuleRow(
      pkg: serializer.fromJson<String>(json['pkg']),
      appClass: serializer.fromJson<String>(json['appClass']),
      keepPolicy: serializer.fromJson<String>(json['keepPolicy']),
      userSet: serializer.fromJson<bool>(json['userSet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pkg': serializer.toJson<String>(pkg),
      'appClass': serializer.toJson<String>(appClass),
      'keepPolicy': serializer.toJson<String>(keepPolicy),
      'userSet': serializer.toJson<bool>(userSet),
    };
  }

  AppRuleRow copyWith({
    String? pkg,
    String? appClass,
    String? keepPolicy,
    bool? userSet,
  }) => AppRuleRow(
    pkg: pkg ?? this.pkg,
    appClass: appClass ?? this.appClass,
    keepPolicy: keepPolicy ?? this.keepPolicy,
    userSet: userSet ?? this.userSet,
  );
  AppRuleRow copyWithCompanion(AppRuleCompanion data) {
    return AppRuleRow(
      pkg: data.pkg.present ? data.pkg.value : this.pkg,
      appClass: data.appClass.present ? data.appClass.value : this.appClass,
      keepPolicy: data.keepPolicy.present
          ? data.keepPolicy.value
          : this.keepPolicy,
      userSet: data.userSet.present ? data.userSet.value : this.userSet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppRuleRow(')
          ..write('pkg: $pkg, ')
          ..write('appClass: $appClass, ')
          ..write('keepPolicy: $keepPolicy, ')
          ..write('userSet: $userSet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pkg, appClass, keepPolicy, userSet);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppRuleRow &&
          other.pkg == this.pkg &&
          other.appClass == this.appClass &&
          other.keepPolicy == this.keepPolicy &&
          other.userSet == this.userSet);
}

class AppRuleCompanion extends UpdateCompanion<AppRuleRow> {
  final Value<String> pkg;
  final Value<String> appClass;
  final Value<String> keepPolicy;
  final Value<bool> userSet;
  final Value<int> rowid;
  const AppRuleCompanion({
    this.pkg = const Value.absent(),
    this.appClass = const Value.absent(),
    this.keepPolicy = const Value.absent(),
    this.userSet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppRuleCompanion.insert({
    required String pkg,
    this.appClass = const Value.absent(),
    this.keepPolicy = const Value.absent(),
    this.userSet = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pkg = Value(pkg);
  static Insertable<AppRuleRow> custom({
    Expression<String>? pkg,
    Expression<String>? appClass,
    Expression<String>? keepPolicy,
    Expression<bool>? userSet,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pkg != null) 'pkg': pkg,
      if (appClass != null) 'class': appClass,
      if (keepPolicy != null) 'keep_policy': keepPolicy,
      if (userSet != null) 'user_set': userSet,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppRuleCompanion copyWith({
    Value<String>? pkg,
    Value<String>? appClass,
    Value<String>? keepPolicy,
    Value<bool>? userSet,
    Value<int>? rowid,
  }) {
    return AppRuleCompanion(
      pkg: pkg ?? this.pkg,
      appClass: appClass ?? this.appClass,
      keepPolicy: keepPolicy ?? this.keepPolicy,
      userSet: userSet ?? this.userSet,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pkg.present) {
      map['pkg'] = Variable<String>(pkg.value);
    }
    if (appClass.present) {
      map['class'] = Variable<String>(appClass.value);
    }
    if (keepPolicy.present) {
      map['keep_policy'] = Variable<String>(keepPolicy.value);
    }
    if (userSet.present) {
      map['user_set'] = Variable<bool>(userSet.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppRuleCompanion(')
          ..write('pkg: $pkg, ')
          ..write('appClass: $appClass, ')
          ..write('keepPolicy: $keepPolicy, ')
          ..write('userSet: $userSet, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChannelScoreTable extends ChannelScore
    with TableInfo<$ChannelScoreTable, ChannelScoreRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelScoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pkgMeta = const VerificationMeta('pkg');
  @override
  late final GeneratedColumn<String> pkg = GeneratedColumn<String>(
    'pkg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [pkg, channel, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channel_score';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelScoreRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pkg')) {
      context.handle(
        _pkgMeta,
        pkg.isAcceptableOrUnknown(data['pkg']!, _pkgMeta),
      );
    } else if (isInserting) {
      context.missing(_pkgMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pkg, channel};
  @override
  ChannelScoreRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelScoreRow(
      pkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pkg'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $ChannelScoreTable createAlias(String alias) {
    return $ChannelScoreTable(attachedDatabase, alias);
  }
}

class ChannelScoreRow extends DataClass implements Insertable<ChannelScoreRow> {
  final String pkg;
  final String channel;
  final int score;
  const ChannelScoreRow({
    required this.pkg,
    required this.channel,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pkg'] = Variable<String>(pkg);
    map['channel'] = Variable<String>(channel);
    map['score'] = Variable<int>(score);
    return map;
  }

  ChannelScoreCompanion toCompanion(bool nullToAbsent) {
    return ChannelScoreCompanion(
      pkg: Value(pkg),
      channel: Value(channel),
      score: Value(score),
    );
  }

  factory ChannelScoreRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelScoreRow(
      pkg: serializer.fromJson<String>(json['pkg']),
      channel: serializer.fromJson<String>(json['channel']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pkg': serializer.toJson<String>(pkg),
      'channel': serializer.toJson<String>(channel),
      'score': serializer.toJson<int>(score),
    };
  }

  ChannelScoreRow copyWith({String? pkg, String? channel, int? score}) =>
      ChannelScoreRow(
        pkg: pkg ?? this.pkg,
        channel: channel ?? this.channel,
        score: score ?? this.score,
      );
  ChannelScoreRow copyWithCompanion(ChannelScoreCompanion data) {
    return ChannelScoreRow(
      pkg: data.pkg.present ? data.pkg.value : this.pkg,
      channel: data.channel.present ? data.channel.value : this.channel,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelScoreRow(')
          ..write('pkg: $pkg, ')
          ..write('channel: $channel, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pkg, channel, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelScoreRow &&
          other.pkg == this.pkg &&
          other.channel == this.channel &&
          other.score == this.score);
}

class ChannelScoreCompanion extends UpdateCompanion<ChannelScoreRow> {
  final Value<String> pkg;
  final Value<String> channel;
  final Value<int> score;
  final Value<int> rowid;
  const ChannelScoreCompanion({
    this.pkg = const Value.absent(),
    this.channel = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelScoreCompanion.insert({
    required String pkg,
    required String channel,
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pkg = Value(pkg),
       channel = Value(channel);
  static Insertable<ChannelScoreRow> custom({
    Expression<String>? pkg,
    Expression<String>? channel,
    Expression<int>? score,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pkg != null) 'pkg': pkg,
      if (channel != null) 'channel': channel,
      if (score != null) 'score': score,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelScoreCompanion copyWith({
    Value<String>? pkg,
    Value<String>? channel,
    Value<int>? score,
    Value<int>? rowid,
  }) {
    return ChannelScoreCompanion(
      pkg: pkg ?? this.pkg,
      channel: channel ?? this.channel,
      score: score ?? this.score,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pkg.present) {
      map['pkg'] = Variable<String>(pkg.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelScoreCompanion(')
          ..write('pkg: $pkg, ')
          ..write('channel: $channel, ')
          ..write('score: $score, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingTable extends Setting with TableInfo<$SettingTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingTable createAlias(String alias) {
    return $SettingTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingCompanion toCompanion(bool nullToAbsent) {
    return SettingCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaySummaryTable extends DaySummary
    with TableInfo<$DaySummaryTable, DayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaySummaryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headlineMeta = const VerificationMeta(
    'headline',
  );
  @override
  late final GeneratedColumn<String> headline = GeneratedColumn<String>(
    'headline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _factsJsonMeta = const VerificationMeta(
    'factsJson',
  );
  @override
  late final GeneratedColumn<String> factsJson = GeneratedColumn<String>(
    'facts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _setAsideCountMeta = const VerificationMeta(
    'setAsideCount',
  );
  @override
  late final GeneratedColumn<int> setAsideCount = GeneratedColumn<int>(
    'set_aside_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    headline,
    factsJson,
    setAsideCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('headline')) {
      context.handle(
        _headlineMeta,
        headline.isAcceptableOrUnknown(data['headline']!, _headlineMeta),
      );
    }
    if (data.containsKey('facts_json')) {
      context.handle(
        _factsJsonMeta,
        factsJson.isAcceptableOrUnknown(data['facts_json']!, _factsJsonMeta),
      );
    }
    if (data.containsKey('set_aside_count')) {
      context.handle(
        _setAsideCountMeta,
        setAsideCount.isAcceptableOrUnknown(
          data['set_aside_count']!,
          _setAsideCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      headline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headline'],
      )!,
      factsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facts_json'],
      )!,
      setAsideCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_aside_count'],
      )!,
    );
  }

  @override
  $DaySummaryTable createAlias(String alias) {
    return $DaySummaryTable(attachedDatabase, alias);
  }
}

class DayRow extends DataClass implements Insertable<DayRow> {
  final String date;
  final String headline;
  final String factsJson;
  final int setAsideCount;
  const DayRow({
    required this.date,
    required this.headline,
    required this.factsJson,
    required this.setAsideCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['headline'] = Variable<String>(headline);
    map['facts_json'] = Variable<String>(factsJson);
    map['set_aside_count'] = Variable<int>(setAsideCount);
    return map;
  }

  DaySummaryCompanion toCompanion(bool nullToAbsent) {
    return DaySummaryCompanion(
      date: Value(date),
      headline: Value(headline),
      factsJson: Value(factsJson),
      setAsideCount: Value(setAsideCount),
    );
  }

  factory DayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayRow(
      date: serializer.fromJson<String>(json['date']),
      headline: serializer.fromJson<String>(json['headline']),
      factsJson: serializer.fromJson<String>(json['factsJson']),
      setAsideCount: serializer.fromJson<int>(json['setAsideCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'headline': serializer.toJson<String>(headline),
      'factsJson': serializer.toJson<String>(factsJson),
      'setAsideCount': serializer.toJson<int>(setAsideCount),
    };
  }

  DayRow copyWith({
    String? date,
    String? headline,
    String? factsJson,
    int? setAsideCount,
  }) => DayRow(
    date: date ?? this.date,
    headline: headline ?? this.headline,
    factsJson: factsJson ?? this.factsJson,
    setAsideCount: setAsideCount ?? this.setAsideCount,
  );
  DayRow copyWithCompanion(DaySummaryCompanion data) {
    return DayRow(
      date: data.date.present ? data.date.value : this.date,
      headline: data.headline.present ? data.headline.value : this.headline,
      factsJson: data.factsJson.present ? data.factsJson.value : this.factsJson,
      setAsideCount: data.setAsideCount.present
          ? data.setAsideCount.value
          : this.setAsideCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayRow(')
          ..write('date: $date, ')
          ..write('headline: $headline, ')
          ..write('factsJson: $factsJson, ')
          ..write('setAsideCount: $setAsideCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, headline, factsJson, setAsideCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayRow &&
          other.date == this.date &&
          other.headline == this.headline &&
          other.factsJson == this.factsJson &&
          other.setAsideCount == this.setAsideCount);
}

class DaySummaryCompanion extends UpdateCompanion<DayRow> {
  final Value<String> date;
  final Value<String> headline;
  final Value<String> factsJson;
  final Value<int> setAsideCount;
  final Value<int> rowid;
  const DaySummaryCompanion({
    this.date = const Value.absent(),
    this.headline = const Value.absent(),
    this.factsJson = const Value.absent(),
    this.setAsideCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaySummaryCompanion.insert({
    required String date,
    this.headline = const Value.absent(),
    this.factsJson = const Value.absent(),
    this.setAsideCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DayRow> custom({
    Expression<String>? date,
    Expression<String>? headline,
    Expression<String>? factsJson,
    Expression<int>? setAsideCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (headline != null) 'headline': headline,
      if (factsJson != null) 'facts_json': factsJson,
      if (setAsideCount != null) 'set_aside_count': setAsideCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaySummaryCompanion copyWith({
    Value<String>? date,
    Value<String>? headline,
    Value<String>? factsJson,
    Value<int>? setAsideCount,
    Value<int>? rowid,
  }) {
    return DaySummaryCompanion(
      date: date ?? this.date,
      headline: headline ?? this.headline,
      factsJson: factsJson ?? this.factsJson,
      setAsideCount: setAsideCount ?? this.setAsideCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (headline.present) {
      map['headline'] = Variable<String>(headline.value);
    }
    if (factsJson.present) {
      map['facts_json'] = Variable<String>(factsJson.value);
    }
    if (setAsideCount.present) {
      map['set_aside_count'] = Variable<int>(setAsideCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaySummaryCompanion(')
          ..write('date: $date, ')
          ..write('headline: $headline, ')
          ..write('factsJson: $factsJson, ')
          ..write('setAsideCount: $setAsideCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MemoryDatabase extends GeneratedDatabase {
  _$MemoryDatabase(QueryExecutor e) : super(e);
  $MemoryDatabaseManager get managers => $MemoryDatabaseManager(this);
  late final $SignalTable signal = $SignalTable(this);
  late final $PersonTable person = $PersonTable(this);
  late final $PersonHandleTable personHandle = $PersonHandleTable(this);
  late final $EntityTable entity = $EntityTable(this);
  late final $SignalEntityTable signalEntity = $SignalEntityTable(this);
  late final $SignalIntentTable signalIntent = $SignalIntentTable(this);
  late final $MemoryThreadTable memoryThread = $MemoryThreadTable(this);
  late final $ThreadSignalTable threadSignal = $ThreadSignalTable(this);
  late final $SignalLinkTable signalLink = $SignalLinkTable(this);
  late final $OpenLoopTable openLoop = $OpenLoopTable(this);
  late final $SeriesTable series = $SeriesTable(this);
  late final $SeriesSignalTable seriesSignal = $SeriesSignalTable(this);
  late final $FeedbackTable feedback = $FeedbackTable(this);
  late final $SuppressRuleTable suppressRule = $SuppressRuleTable(this);
  late final $AppRuleTable appRule = $AppRuleTable(this);
  late final $ChannelScoreTable channelScore = $ChannelScoreTable(this);
  late final $SettingTable setting = $SettingTable(this);
  late final $DaySummaryTable daySummary = $DaySummaryTable(this);
  late final Index idxSignalOccurredAt = Index(
    'idx_signal_occurred_at',
    'CREATE INDEX idx_signal_occurred_at ON signal (occurred_at)',
  );
  late final Index idxSignalSbnKey = Index(
    'idx_signal_sbn_key',
    'CREATE INDEX idx_signal_sbn_key ON signal (sbn_key)',
  );
  late final Index idxThreadLastAt = Index(
    'idx_thread_last_at',
    'CREATE INDEX idx_thread_last_at ON thread (last_at)',
  );
  late final Index idxOpenLoopDueAt = Index(
    'idx_open_loop_due_at',
    'CREATE INDEX idx_open_loop_due_at ON open_loop (due_at)',
  );
  late final Index idxSeriesNextFrom = Index(
    'idx_series_next_from',
    'CREATE INDEX idx_series_next_from ON series (next_from)',
  );
  late final Index idxFeedbackAt = Index(
    'idx_feedback_at',
    'CREATE INDEX idx_feedback_at ON feedback (at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    signal,
    person,
    personHandle,
    entity,
    signalEntity,
    signalIntent,
    memoryThread,
    threadSignal,
    signalLink,
    openLoop,
    series,
    seriesSignal,
    feedback,
    suppressRule,
    appRule,
    channelScore,
    setting,
    daySummary,
    idxSignalOccurredAt,
    idxSignalSbnKey,
    idxThreadLastAt,
    idxOpenLoopDueAt,
    idxSeriesNextFrom,
    idxFeedbackAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'person',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('person_handle', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_entity', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entity',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('signal_entity', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intent', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'thread',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('thread_signal', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('thread_signal', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'thread',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('link', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('link', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'thread',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('open_loop', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'series',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('series_signal', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signal',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('series_signal', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SignalTableCreateCompanionBuilder =
    SignalCompanion Function({
      Value<int> id,
      Value<int?> inboxId,
      required String source,
      Value<String> pkg,
      Value<String> kind,
      Value<String?> sbnKey,
      Value<String> title,
      Value<String> body,
      required int occurredAt,
      Value<int?> endedAt,
      Value<int?> personId,
      Value<String> signalClass,
      Value<bool> kept,
      Value<bool> redacted,
      Value<String> extrasJson,
      Value<int?> deletedAt,
    });
typedef $$SignalTableUpdateCompanionBuilder =
    SignalCompanion Function({
      Value<int> id,
      Value<int?> inboxId,
      Value<String> source,
      Value<String> pkg,
      Value<String> kind,
      Value<String?> sbnKey,
      Value<String> title,
      Value<String> body,
      Value<int> occurredAt,
      Value<int?> endedAt,
      Value<int?> personId,
      Value<String> signalClass,
      Value<bool> kept,
      Value<bool> redacted,
      Value<String> extrasJson,
      Value<int?> deletedAt,
    });

final class $$SignalTableReferences
    extends BaseReferences<_$MemoryDatabase, $SignalTable, SignalRow> {
  $$SignalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SignalEntityTable, List<SignalEntityRow>>
  _signalEntityRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.signalEntity,
    aliasName: 'signal__id__signal_entity__signal_id',
  );

  $$SignalEntityTableProcessedTableManager get signalEntityRefs {
    final manager = $$SignalEntityTableTableManager(
      $_db,
      $_db.signalEntity,
    ).filter((f) => f.signalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalEntityRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalIntentTable, List<IntentRow>>
  _signalIntentRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.signalIntent,
    aliasName: 'signal__id__intent__signal_id',
  );

  $$SignalIntentTableProcessedTableManager get signalIntentRefs {
    final manager = $$SignalIntentTableTableManager(
      $_db,
      $_db.signalIntent,
    ).filter((f) => f.signalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalIntentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ThreadSignalTable, List<ThreadSignalRow>>
  _threadSignalRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.threadSignal,
    aliasName: 'signal__id__thread_signal__signal_id',
  );

  $$ThreadSignalTableProcessedTableManager get threadSignalRefs {
    final manager = $$ThreadSignalTableTableManager(
      $_db,
      $_db.threadSignal,
    ).filter((f) => f.signalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_threadSignalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalLinkTable, List<LinkRow>>
  _signalLinkRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.signalLink,
    aliasName: 'signal__id__link__signal_id',
  );

  $$SignalLinkTableProcessedTableManager get signalLinkRefs {
    final manager = $$SignalLinkTableTableManager(
      $_db,
      $_db.signalLink,
    ).filter((f) => f.signalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalLinkRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesSignalTable, List<SeriesSignalRow>>
  _seriesSignalRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesSignal,
    aliasName: 'signal__id__series_signal__signal_id',
  );

  $$SeriesSignalTableProcessedTableManager get seriesSignalRefs {
    final manager = $$SeriesSignalTableTableManager(
      $_db,
      $_db.seriesSignal,
    ).filter((f) => f.signalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesSignalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SignalTableFilterComposer
    extends Composer<_$MemoryDatabase, $SignalTable> {
  $$SignalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inboxId => $composableBuilder(
    column: $table.inboxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sbnKey => $composableBuilder(
    column: $table.sbnKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signalClass => $composableBuilder(
    column: $table.signalClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kept => $composableBuilder(
    column: $table.kept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get redacted => $composableBuilder(
    column: $table.redacted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> signalEntityRefs(
    Expression<bool> Function($$SignalEntityTableFilterComposer f) f,
  ) {
    final $$SignalEntityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEntity,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEntityTableFilterComposer(
            $db: $db,
            $table: $db.signalEntity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> signalIntentRefs(
    Expression<bool> Function($$SignalIntentTableFilterComposer f) f,
  ) {
    final $$SignalIntentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalIntent,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalIntentTableFilterComposer(
            $db: $db,
            $table: $db.signalIntent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> threadSignalRefs(
    Expression<bool> Function($$ThreadSignalTableFilterComposer f) f,
  ) {
    final $$ThreadSignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.threadSignal,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThreadSignalTableFilterComposer(
            $db: $db,
            $table: $db.threadSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> signalLinkRefs(
    Expression<bool> Function($$SignalLinkTableFilterComposer f) f,
  ) {
    final $$SignalLinkTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalLink,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalLinkTableFilterComposer(
            $db: $db,
            $table: $db.signalLink,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesSignalRefs(
    Expression<bool> Function($$SeriesSignalTableFilterComposer f) f,
  ) {
    final $$SeriesSignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSignal,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSignalTableFilterComposer(
            $db: $db,
            $table: $db.seriesSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SignalTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SignalTable> {
  $$SignalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inboxId => $composableBuilder(
    column: $table.inboxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sbnKey => $composableBuilder(
    column: $table.sbnKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signalClass => $composableBuilder(
    column: $table.signalClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kept => $composableBuilder(
    column: $table.kept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get redacted => $composableBuilder(
    column: $table.redacted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SignalTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SignalTable> {
  $$SignalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get inboxId =>
      $composableBuilder(column: $table.inboxId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get pkg =>
      $composableBuilder(column: $table.pkg, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get sbnKey =>
      $composableBuilder(column: $table.sbnKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get signalClass => $composableBuilder(
    column: $table.signalClass,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get kept =>
      $composableBuilder(column: $table.kept, builder: (column) => column);

  GeneratedColumn<bool> get redacted =>
      $composableBuilder(column: $table.redacted, builder: (column) => column);

  GeneratedColumn<String> get extrasJson => $composableBuilder(
    column: $table.extrasJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> signalEntityRefs<T extends Object>(
    Expression<T> Function($$SignalEntityTableAnnotationComposer a) f,
  ) {
    final $$SignalEntityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEntity,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEntityTableAnnotationComposer(
            $db: $db,
            $table: $db.signalEntity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> signalIntentRefs<T extends Object>(
    Expression<T> Function($$SignalIntentTableAnnotationComposer a) f,
  ) {
    final $$SignalIntentTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalIntent,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalIntentTableAnnotationComposer(
            $db: $db,
            $table: $db.signalIntent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> threadSignalRefs<T extends Object>(
    Expression<T> Function($$ThreadSignalTableAnnotationComposer a) f,
  ) {
    final $$ThreadSignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.threadSignal,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThreadSignalTableAnnotationComposer(
            $db: $db,
            $table: $db.threadSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> signalLinkRefs<T extends Object>(
    Expression<T> Function($$SignalLinkTableAnnotationComposer a) f,
  ) {
    final $$SignalLinkTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalLink,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalLinkTableAnnotationComposer(
            $db: $db,
            $table: $db.signalLink,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesSignalRefs<T extends Object>(
    Expression<T> Function($$SeriesSignalTableAnnotationComposer a) f,
  ) {
    final $$SeriesSignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSignal,
      getReferencedColumn: (t) => t.signalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSignalTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SignalTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SignalTable,
          SignalRow,
          $$SignalTableFilterComposer,
          $$SignalTableOrderingComposer,
          $$SignalTableAnnotationComposer,
          $$SignalTableCreateCompanionBuilder,
          $$SignalTableUpdateCompanionBuilder,
          (SignalRow, $$SignalTableReferences),
          SignalRow,
          PrefetchHooks Function({
            bool signalEntityRefs,
            bool signalIntentRefs,
            bool threadSignalRefs,
            bool signalLinkRefs,
            bool seriesSignalRefs,
          })
        > {
  $$SignalTableTableManager(_$MemoryDatabase db, $SignalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> inboxId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> pkg = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> sbnKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int?> personId = const Value.absent(),
                Value<String> signalClass = const Value.absent(),
                Value<bool> kept = const Value.absent(),
                Value<bool> redacted = const Value.absent(),
                Value<String> extrasJson = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => SignalCompanion(
                id: id,
                inboxId: inboxId,
                source: source,
                pkg: pkg,
                kind: kind,
                sbnKey: sbnKey,
                title: title,
                body: body,
                occurredAt: occurredAt,
                endedAt: endedAt,
                personId: personId,
                signalClass: signalClass,
                kept: kept,
                redacted: redacted,
                extrasJson: extrasJson,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> inboxId = const Value.absent(),
                required String source,
                Value<String> pkg = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> sbnKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                required int occurredAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int?> personId = const Value.absent(),
                Value<String> signalClass = const Value.absent(),
                Value<bool> kept = const Value.absent(),
                Value<bool> redacted = const Value.absent(),
                Value<String> extrasJson = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
              }) => SignalCompanion.insert(
                id: id,
                inboxId: inboxId,
                source: source,
                pkg: pkg,
                kind: kind,
                sbnKey: sbnKey,
                title: title,
                body: body,
                occurredAt: occurredAt,
                endedAt: endedAt,
                personId: personId,
                signalClass: signalClass,
                kept: kept,
                redacted: redacted,
                extrasJson: extrasJson,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SignalTable, SignalRow>(table),
                  $$SignalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                signalEntityRefs = false,
                signalIntentRefs = false,
                threadSignalRefs = false,
                signalLinkRefs = false,
                seriesSignalRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (signalEntityRefs) db.signalEntity,
                    if (signalIntentRefs) db.signalIntent,
                    if (threadSignalRefs) db.threadSignal,
                    if (signalLinkRefs) db.signalLink,
                    if (seriesSignalRefs) db.seriesSignal,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (signalEntityRefs)
                        await $_getPrefetchedDataByColumns<
                          SignalRow,
                          $SignalTable,
                          SignalEntityRow,
                          $SignalEntityTable
                        >(
                          currentTable: table,
                          referencedTable: $$SignalTableReferences
                              ._signalEntityRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalTableReferences(
                                db,
                                table,
                                p0,
                              ).signalEntityRefs,
                          currentColumn: 'id',
                          referencedColumn: 'signal_id',
                          typedResults: items,
                        ),
                      if (signalIntentRefs)
                        await $_getPrefetchedDataByColumns<
                          SignalRow,
                          $SignalTable,
                          IntentRow,
                          $SignalIntentTable
                        >(
                          currentTable: table,
                          referencedTable: $$SignalTableReferences
                              ._signalIntentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalTableReferences(
                                db,
                                table,
                                p0,
                              ).signalIntentRefs,
                          currentColumn: 'id',
                          referencedColumn: 'signal_id',
                          typedResults: items,
                        ),
                      if (threadSignalRefs)
                        await $_getPrefetchedDataByColumns<
                          SignalRow,
                          $SignalTable,
                          ThreadSignalRow,
                          $ThreadSignalTable
                        >(
                          currentTable: table,
                          referencedTable: $$SignalTableReferences
                              ._threadSignalRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalTableReferences(
                                db,
                                table,
                                p0,
                              ).threadSignalRefs,
                          currentColumn: 'id',
                          referencedColumn: 'signal_id',
                          typedResults: items,
                        ),
                      if (signalLinkRefs)
                        await $_getPrefetchedDataByColumns<
                          SignalRow,
                          $SignalTable,
                          LinkRow,
                          $SignalLinkTable
                        >(
                          currentTable: table,
                          referencedTable: $$SignalTableReferences
                              ._signalLinkRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalTableReferences(
                                db,
                                table,
                                p0,
                              ).signalLinkRefs,
                          currentColumn: 'id',
                          referencedColumn: 'signal_id',
                          typedResults: items,
                        ),
                      if (seriesSignalRefs)
                        await $_getPrefetchedDataByColumns<
                          SignalRow,
                          $SignalTable,
                          SeriesSignalRow,
                          $SeriesSignalTable
                        >(
                          currentTable: table,
                          referencedTable: $$SignalTableReferences
                              ._seriesSignalRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SignalTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesSignalRefs,
                          currentColumn: 'id',
                          referencedColumn: 'signal_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SignalTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SignalTable,
      SignalRow,
      $$SignalTableFilterComposer,
      $$SignalTableOrderingComposer,
      $$SignalTableAnnotationComposer,
      $$SignalTableCreateCompanionBuilder,
      $$SignalTableUpdateCompanionBuilder,
      (SignalRow, $$SignalTableReferences),
      SignalRow,
      PrefetchHooks Function({
        bool signalEntityRefs,
        bool signalIntentRefs,
        bool threadSignalRefs,
        bool signalLinkRefs,
        bool seriesSignalRefs,
      })
    >;
typedef $$PersonTableCreateCompanionBuilder =
    PersonCompanion Function({
      Value<int> id,
      required String displayName,
      Value<String?> contactLookupKey,
      Value<bool> isMe,
    });
typedef $$PersonTableUpdateCompanionBuilder =
    PersonCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String?> contactLookupKey,
      Value<bool> isMe,
    });

final class $$PersonTableReferences
    extends BaseReferences<_$MemoryDatabase, $PersonTable, PersonRow> {
  $$PersonTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonHandleTable, List<PersonHandleRow>>
  _personHandleRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.personHandle,
    aliasName: 'person__id__person_handle__person_id',
  );

  $$PersonHandleTableProcessedTableManager get personHandleRefs {
    final manager = $$PersonHandleTableTableManager(
      $_db,
      $_db.personHandle,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_personHandleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonTableFilterComposer
    extends Composer<_$MemoryDatabase, $PersonTable> {
  $$PersonTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactLookupKey => $composableBuilder(
    column: $table.contactLookupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personHandleRefs(
    Expression<bool> Function($$PersonHandleTableFilterComposer f) f,
  ) {
    final $$PersonHandleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personHandle,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonHandleTableFilterComposer(
            $db: $db,
            $table: $db.personHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonTableOrderingComposer
    extends Composer<_$MemoryDatabase, $PersonTable> {
  $$PersonTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactLookupKey => $composableBuilder(
    column: $table.contactLookupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $PersonTable> {
  $$PersonTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactLookupKey => $composableBuilder(
    column: $table.contactLookupKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);

  Expression<T> personHandleRefs<T extends Object>(
    Expression<T> Function($$PersonHandleTableAnnotationComposer a) f,
  ) {
    final $$PersonHandleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personHandle,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonHandleTableAnnotationComposer(
            $db: $db,
            $table: $db.personHandle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $PersonTable,
          PersonRow,
          $$PersonTableFilterComposer,
          $$PersonTableOrderingComposer,
          $$PersonTableAnnotationComposer,
          $$PersonTableCreateCompanionBuilder,
          $$PersonTableUpdateCompanionBuilder,
          (PersonRow, $$PersonTableReferences),
          PersonRow,
          PrefetchHooks Function({bool personHandleRefs})
        > {
  $$PersonTableTableManager(_$MemoryDatabase db, $PersonTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> contactLookupKey = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
              }) => PersonCompanion(
                id: id,
                displayName: displayName,
                contactLookupKey: contactLookupKey,
                isMe: isMe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                Value<String?> contactLookupKey = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
              }) => PersonCompanion.insert(
                id: id,
                displayName: displayName,
                contactLookupKey: contactLookupKey,
                isMe: isMe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonTable, PersonRow>(table),
                  $$PersonTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personHandleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (personHandleRefs) db.personHandle],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (personHandleRefs)
                    await $_getPrefetchedDataByColumns<
                      PersonRow,
                      $PersonTable,
                      PersonHandleRow,
                      $PersonHandleTable
                    >(
                      currentTable: table,
                      referencedTable: $$PersonTableReferences
                          ._personHandleRefsTable(db),
                      managerFromTypedResult: (p0) => $$PersonTableReferences(
                        db,
                        table,
                        p0,
                      ).personHandleRefs,
                      currentColumn: 'id',
                      referencedColumn: 'person_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PersonTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $PersonTable,
      PersonRow,
      $$PersonTableFilterComposer,
      $$PersonTableOrderingComposer,
      $$PersonTableAnnotationComposer,
      $$PersonTableCreateCompanionBuilder,
      $$PersonTableUpdateCompanionBuilder,
      (PersonRow, $$PersonTableReferences),
      PersonRow,
      PrefetchHooks Function({bool personHandleRefs})
    >;
typedef $$PersonHandleTableCreateCompanionBuilder =
    PersonHandleCompanion Function({
      Value<int> id,
      required int personId,
      required String type,
      required String value,
      Value<String> app,
    });
typedef $$PersonHandleTableUpdateCompanionBuilder =
    PersonHandleCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<String> type,
      Value<String> value,
      Value<String> app,
    });

final class $$PersonHandleTableReferences
    extends
        BaseReferences<_$MemoryDatabase, $PersonHandleTable, PersonHandleRow> {
  $$PersonHandleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PersonTable _personIdTable(_$MemoryDatabase db) =>
      db.person.createAlias('person_handle__person_id__person__id');

  $$PersonTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PersonTableTableManager(
      $_db,
      $_db.person,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonHandleTableFilterComposer
    extends Composer<_$MemoryDatabase, $PersonHandleTable> {
  $$PersonHandleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonTableFilterComposer get personId {
    final $$PersonTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.person,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonTableFilterComposer(
            $db: $db,
            $table: $db.person,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonHandleTableOrderingComposer
    extends Composer<_$MemoryDatabase, $PersonHandleTable> {
  $$PersonHandleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get app => $composableBuilder(
    column: $table.app,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonTableOrderingComposer get personId {
    final $$PersonTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.person,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonTableOrderingComposer(
            $db: $db,
            $table: $db.person,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonHandleTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $PersonHandleTable> {
  $$PersonHandleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get app =>
      $composableBuilder(column: $table.app, builder: (column) => column);

  $$PersonTableAnnotationComposer get personId {
    final $$PersonTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.person,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonTableAnnotationComposer(
            $db: $db,
            $table: $db.person,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonHandleTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $PersonHandleTable,
          PersonHandleRow,
          $$PersonHandleTableFilterComposer,
          $$PersonHandleTableOrderingComposer,
          $$PersonHandleTableAnnotationComposer,
          $$PersonHandleTableCreateCompanionBuilder,
          $$PersonHandleTableUpdateCompanionBuilder,
          (PersonHandleRow, $$PersonHandleTableReferences),
          PersonHandleRow,
          PrefetchHooks Function({bool personId})
        > {
  $$PersonHandleTableTableManager(_$MemoryDatabase db, $PersonHandleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonHandleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonHandleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonHandleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> app = const Value.absent(),
              }) => PersonHandleCompanion(
                id: id,
                personId: personId,
                type: type,
                value: value,
                app: app,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                required String type,
                required String value,
                Value<String> app = const Value.absent(),
              }) => PersonHandleCompanion.insert(
                id: id,
                personId: personId,
                type: type,
                value: value,
                app: app,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonHandleTable, PersonHandleRow>(table),
                  $$PersonHandleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$PersonHandleTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$PersonHandleTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonHandleTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $PersonHandleTable,
      PersonHandleRow,
      $$PersonHandleTableFilterComposer,
      $$PersonHandleTableOrderingComposer,
      $$PersonHandleTableAnnotationComposer,
      $$PersonHandleTableCreateCompanionBuilder,
      $$PersonHandleTableUpdateCompanionBuilder,
      (PersonHandleRow, $$PersonHandleTableReferences),
      PersonHandleRow,
      PrefetchHooks Function({bool personId})
    >;
typedef $$EntityTableCreateCompanionBuilder =
    EntityCompanion Function({
      Value<int> id,
      required String type,
      required String canonicalValue,
      required String display,
    });
typedef $$EntityTableUpdateCompanionBuilder =
    EntityCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> canonicalValue,
      Value<String> display,
    });

final class $$EntityTableReferences
    extends BaseReferences<_$MemoryDatabase, $EntityTable, EntityRow> {
  $$EntityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SignalEntityTable, List<SignalEntityRow>>
  _signalEntityRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.signalEntity,
    aliasName: 'entity__id__signal_entity__entity_id',
  );

  $$SignalEntityTableProcessedTableManager get signalEntityRefs {
    final manager = $$SignalEntityTableTableManager(
      $_db,
      $_db.signalEntity,
    ).filter((f) => f.entityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalEntityRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntityTableFilterComposer
    extends Composer<_$MemoryDatabase, $EntityTable> {
  $$EntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalValue => $composableBuilder(
    column: $table.canonicalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> signalEntityRefs(
    Expression<bool> Function($$SignalEntityTableFilterComposer f) f,
  ) {
    final $$SignalEntityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEntity,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEntityTableFilterComposer(
            $db: $db,
            $table: $db.signalEntity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntityTableOrderingComposer
    extends Composer<_$MemoryDatabase, $EntityTable> {
  $$EntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalValue => $composableBuilder(
    column: $table.canonicalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $EntityTable> {
  $$EntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get canonicalValue => $composableBuilder(
    column: $table.canonicalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get display =>
      $composableBuilder(column: $table.display, builder: (column) => column);

  Expression<T> signalEntityRefs<T extends Object>(
    Expression<T> Function($$SignalEntityTableAnnotationComposer a) f,
  ) {
    final $$SignalEntityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalEntity,
      getReferencedColumn: (t) => t.entityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalEntityTableAnnotationComposer(
            $db: $db,
            $table: $db.signalEntity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntityTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $EntityTable,
          EntityRow,
          $$EntityTableFilterComposer,
          $$EntityTableOrderingComposer,
          $$EntityTableAnnotationComposer,
          $$EntityTableCreateCompanionBuilder,
          $$EntityTableUpdateCompanionBuilder,
          (EntityRow, $$EntityTableReferences),
          EntityRow,
          PrefetchHooks Function({bool signalEntityRefs})
        > {
  $$EntityTableTableManager(_$MemoryDatabase db, $EntityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> canonicalValue = const Value.absent(),
                Value<String> display = const Value.absent(),
              }) => EntityCompanion(
                id: id,
                type: type,
                canonicalValue: canonicalValue,
                display: display,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String canonicalValue,
                required String display,
              }) => EntityCompanion.insert(
                id: id,
                type: type,
                canonicalValue: canonicalValue,
                display: display,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntityTable, EntityRow>(table),
                  $$EntityTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({signalEntityRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (signalEntityRefs) db.signalEntity],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (signalEntityRefs)
                    await $_getPrefetchedDataByColumns<
                      EntityRow,
                      $EntityTable,
                      SignalEntityRow,
                      $SignalEntityTable
                    >(
                      currentTable: table,
                      referencedTable: $$EntityTableReferences
                          ._signalEntityRefsTable(db),
                      managerFromTypedResult: (p0) => $$EntityTableReferences(
                        db,
                        table,
                        p0,
                      ).signalEntityRefs,
                      currentColumn: 'id',
                      referencedColumn: 'entity_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EntityTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $EntityTable,
      EntityRow,
      $$EntityTableFilterComposer,
      $$EntityTableOrderingComposer,
      $$EntityTableAnnotationComposer,
      $$EntityTableCreateCompanionBuilder,
      $$EntityTableUpdateCompanionBuilder,
      (EntityRow, $$EntityTableReferences),
      EntityRow,
      PrefetchHooks Function({bool signalEntityRefs})
    >;
typedef $$SignalEntityTableCreateCompanionBuilder =
    SignalEntityCompanion Function({
      required int signalId,
      required int entityId,
      Value<String> role,
      Value<int> rowid,
    });
typedef $$SignalEntityTableUpdateCompanionBuilder =
    SignalEntityCompanion Function({
      Value<int> signalId,
      Value<int> entityId,
      Value<String> role,
      Value<int> rowid,
    });

final class $$SignalEntityTableReferences
    extends
        BaseReferences<_$MemoryDatabase, $SignalEntityTable, SignalEntityRow> {
  $$SignalEntityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SignalTable _signalIdTable(_$MemoryDatabase db) =>
      db.signal.createAlias('signal_entity__signal_id__signal__id');

  $$SignalTableProcessedTableManager get signalId {
    final $_column = $_itemColumn<int>('signal_id')!;

    final manager = $$SignalTableTableManager(
      $_db,
      $_db.signal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EntityTable _entityIdTable(_$MemoryDatabase db) =>
      db.entity.createAlias('signal_entity__entity_id__entity__id');

  $$EntityTableProcessedTableManager get entityId {
    final $_column = $_itemColumn<int>('entity_id')!;

    final manager = $$EntityTableTableManager(
      $_db,
      $_db.entity,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SignalEntityTableFilterComposer
    extends Composer<_$MemoryDatabase, $SignalEntityTable> {
  $$SignalEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$SignalTableFilterComposer get signalId {
    final $$SignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableFilterComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntityTableFilterComposer get entityId {
    final $$EntityTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entity,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTableFilterComposer(
            $db: $db,
            $table: $db.entity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEntityTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SignalEntityTable> {
  $$SignalEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$SignalTableOrderingComposer get signalId {
    final $$SignalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableOrderingComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntityTableOrderingComposer get entityId {
    final $$EntityTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entity,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTableOrderingComposer(
            $db: $db,
            $table: $db.entity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEntityTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SignalEntityTable> {
  $$SignalEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$SignalTableAnnotationComposer get signalId {
    final $$SignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableAnnotationComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EntityTableAnnotationComposer get entityId {
    final $$EntityTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entityId,
      referencedTable: $db.entity,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntityTableAnnotationComposer(
            $db: $db,
            $table: $db.entity,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalEntityTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SignalEntityTable,
          SignalEntityRow,
          $$SignalEntityTableFilterComposer,
          $$SignalEntityTableOrderingComposer,
          $$SignalEntityTableAnnotationComposer,
          $$SignalEntityTableCreateCompanionBuilder,
          $$SignalEntityTableUpdateCompanionBuilder,
          (SignalEntityRow, $$SignalEntityTableReferences),
          SignalEntityRow,
          PrefetchHooks Function({bool signalId, bool entityId})
        > {
  $$SignalEntityTableTableManager(_$MemoryDatabase db, $SignalEntityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> signalId = const Value.absent(),
                Value<int> entityId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalEntityCompanion(
                signalId: signalId,
                entityId: entityId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int signalId,
                required int entityId,
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignalEntityCompanion.insert(
                signalId: signalId,
                entityId: entityId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SignalEntityTable, SignalEntityRow>(table),
                  $$SignalEntityTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({signalId = false, entityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (signalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.signalId,
                                referencedTable: $$SignalEntityTableReferences
                                    ._signalIdTable(db),
                                referencedColumn: $$SignalEntityTableReferences
                                    ._signalIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (entityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entityId,
                                referencedTable: $$SignalEntityTableReferences
                                    ._entityIdTable(db),
                                referencedColumn: $$SignalEntityTableReferences
                                    ._entityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SignalEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SignalEntityTable,
      SignalEntityRow,
      $$SignalEntityTableFilterComposer,
      $$SignalEntityTableOrderingComposer,
      $$SignalEntityTableAnnotationComposer,
      $$SignalEntityTableCreateCompanionBuilder,
      $$SignalEntityTableUpdateCompanionBuilder,
      (SignalEntityRow, $$SignalEntityTableReferences),
      SignalEntityRow,
      PrefetchHooks Function({bool signalId, bool entityId})
    >;
typedef $$SignalIntentTableCreateCompanionBuilder =
    SignalIntentCompanion Function({
      Value<int> id,
      required int signalId,
      required String type,
      required String content,
      Value<int?> dueAt,
      Value<double> confidence,
    });
typedef $$SignalIntentTableUpdateCompanionBuilder =
    SignalIntentCompanion Function({
      Value<int> id,
      Value<int> signalId,
      Value<String> type,
      Value<String> content,
      Value<int?> dueAt,
      Value<double> confidence,
    });

final class $$SignalIntentTableReferences
    extends BaseReferences<_$MemoryDatabase, $SignalIntentTable, IntentRow> {
  $$SignalIntentTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SignalTable _signalIdTable(_$MemoryDatabase db) =>
      db.signal.createAlias('intent__signal_id__signal__id');

  $$SignalTableProcessedTableManager get signalId {
    final $_column = $_itemColumn<int>('signal_id')!;

    final manager = $$SignalTableTableManager(
      $_db,
      $_db.signal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SignalIntentTableFilterComposer
    extends Composer<_$MemoryDatabase, $SignalIntentTable> {
  $$SignalIntentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$SignalTableFilterComposer get signalId {
    final $$SignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableFilterComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalIntentTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SignalIntentTable> {
  $$SignalIntentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$SignalTableOrderingComposer get signalId {
    final $$SignalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableOrderingComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalIntentTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SignalIntentTable> {
  $$SignalIntentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$SignalTableAnnotationComposer get signalId {
    final $$SignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableAnnotationComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalIntentTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SignalIntentTable,
          IntentRow,
          $$SignalIntentTableFilterComposer,
          $$SignalIntentTableOrderingComposer,
          $$SignalIntentTableAnnotationComposer,
          $$SignalIntentTableCreateCompanionBuilder,
          $$SignalIntentTableUpdateCompanionBuilder,
          (IntentRow, $$SignalIntentTableReferences),
          IntentRow,
          PrefetchHooks Function({bool signalId})
        > {
  $$SignalIntentTableTableManager(_$MemoryDatabase db, $SignalIntentTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalIntentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalIntentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalIntentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> signalId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
              }) => SignalIntentCompanion(
                id: id,
                signalId: signalId,
                type: type,
                content: content,
                dueAt: dueAt,
                confidence: confidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int signalId,
                required String type,
                required String content,
                Value<int?> dueAt = const Value.absent(),
                Value<double> confidence = const Value.absent(),
              }) => SignalIntentCompanion.insert(
                id: id,
                signalId: signalId,
                type: type,
                content: content,
                dueAt: dueAt,
                confidence: confidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SignalIntentTable, IntentRow>(table),
                  $$SignalIntentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({signalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (signalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.signalId,
                                referencedTable: $$SignalIntentTableReferences
                                    ._signalIdTable(db),
                                referencedColumn: $$SignalIntentTableReferences
                                    ._signalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SignalIntentTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SignalIntentTable,
      IntentRow,
      $$SignalIntentTableFilterComposer,
      $$SignalIntentTableOrderingComposer,
      $$SignalIntentTableAnnotationComposer,
      $$SignalIntentTableCreateCompanionBuilder,
      $$SignalIntentTableUpdateCompanionBuilder,
      (IntentRow, $$SignalIntentTableReferences),
      IntentRow,
      PrefetchHooks Function({bool signalId})
    >;
typedef $$MemoryThreadTableCreateCompanionBuilder =
    MemoryThreadCompanion Function({
      Value<int> id,
      required String title,
      Value<String> kind,
      Value<int?> personId,
      required int startedAt,
      required int lastAt,
      Value<String> status,
      Value<bool> userEdited,
    });
typedef $$MemoryThreadTableUpdateCompanionBuilder =
    MemoryThreadCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> kind,
      Value<int?> personId,
      Value<int> startedAt,
      Value<int> lastAt,
      Value<String> status,
      Value<bool> userEdited,
    });

final class $$MemoryThreadTableReferences
    extends BaseReferences<_$MemoryDatabase, $MemoryThreadTable, ThreadRow> {
  $$MemoryThreadTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ThreadSignalTable, List<ThreadSignalRow>>
  _threadSignalRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.threadSignal,
    aliasName: 'thread__id__thread_signal__thread_id',
  );

  $$ThreadSignalTableProcessedTableManager get threadSignalRefs {
    final manager = $$ThreadSignalTableTableManager(
      $_db,
      $_db.threadSignal,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_threadSignalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SignalLinkTable, List<LinkRow>>
  _signalLinkRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.signalLink,
    aliasName: 'thread__id__link__thread_id',
  );

  $$SignalLinkTableProcessedTableManager get signalLinkRefs {
    final manager = $$SignalLinkTableTableManager(
      $_db,
      $_db.signalLink,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_signalLinkRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OpenLoopTable, List<OpenLoopRow>>
  _openLoopRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.openLoop,
    aliasName: 'thread__id__open_loop__thread_id',
  );

  $$OpenLoopTableProcessedTableManager get openLoopRefs {
    final manager = $$OpenLoopTableTableManager(
      $_db,
      $_db.openLoop,
    ).filter((f) => f.threadId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_openLoopRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryThreadTableFilterComposer
    extends Composer<_$MemoryDatabase, $MemoryThreadTable> {
  $$MemoryThreadTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> threadSignalRefs(
    Expression<bool> Function($$ThreadSignalTableFilterComposer f) f,
  ) {
    final $$ThreadSignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.threadSignal,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThreadSignalTableFilterComposer(
            $db: $db,
            $table: $db.threadSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> signalLinkRefs(
    Expression<bool> Function($$SignalLinkTableFilterComposer f) f,
  ) {
    final $$SignalLinkTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalLink,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalLinkTableFilterComposer(
            $db: $db,
            $table: $db.signalLink,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> openLoopRefs(
    Expression<bool> Function($$OpenLoopTableFilterComposer f) f,
  ) {
    final $$OpenLoopTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openLoop,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenLoopTableFilterComposer(
            $db: $db,
            $table: $db.openLoop,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryThreadTableOrderingComposer
    extends Composer<_$MemoryDatabase, $MemoryThreadTable> {
  $$MemoryThreadTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAt => $composableBuilder(
    column: $table.lastAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryThreadTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $MemoryThreadTable> {
  $$MemoryThreadTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => column,
  );

  Expression<T> threadSignalRefs<T extends Object>(
    Expression<T> Function($$ThreadSignalTableAnnotationComposer a) f,
  ) {
    final $$ThreadSignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.threadSignal,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ThreadSignalTableAnnotationComposer(
            $db: $db,
            $table: $db.threadSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> signalLinkRefs<T extends Object>(
    Expression<T> Function($$SignalLinkTableAnnotationComposer a) f,
  ) {
    final $$SignalLinkTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.signalLink,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalLinkTableAnnotationComposer(
            $db: $db,
            $table: $db.signalLink,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> openLoopRefs<T extends Object>(
    Expression<T> Function($$OpenLoopTableAnnotationComposer a) f,
  ) {
    final $$OpenLoopTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.openLoop,
      getReferencedColumn: (t) => t.threadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpenLoopTableAnnotationComposer(
            $db: $db,
            $table: $db.openLoop,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryThreadTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $MemoryThreadTable,
          ThreadRow,
          $$MemoryThreadTableFilterComposer,
          $$MemoryThreadTableOrderingComposer,
          $$MemoryThreadTableAnnotationComposer,
          $$MemoryThreadTableCreateCompanionBuilder,
          $$MemoryThreadTableUpdateCompanionBuilder,
          (ThreadRow, $$MemoryThreadTableReferences),
          ThreadRow,
          PrefetchHooks Function({
            bool threadSignalRefs,
            bool signalLinkRefs,
            bool openLoopRefs,
          })
        > {
  $$MemoryThreadTableTableManager(_$MemoryDatabase db, $MemoryThreadTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryThreadTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryThreadTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryThreadTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> personId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> lastAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
              }) => MemoryThreadCompanion(
                id: id,
                title: title,
                kind: kind,
                personId: personId,
                startedAt: startedAt,
                lastAt: lastAt,
                status: status,
                userEdited: userEdited,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> kind = const Value.absent(),
                Value<int?> personId = const Value.absent(),
                required int startedAt,
                required int lastAt,
                Value<String> status = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
              }) => MemoryThreadCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                personId: personId,
                startedAt: startedAt,
                lastAt: lastAt,
                status: status,
                userEdited: userEdited,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryThreadTable, ThreadRow>(table),
                  $$MemoryThreadTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                threadSignalRefs = false,
                signalLinkRefs = false,
                openLoopRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (threadSignalRefs) db.threadSignal,
                    if (signalLinkRefs) db.signalLink,
                    if (openLoopRefs) db.openLoop,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (threadSignalRefs)
                        await $_getPrefetchedDataByColumns<
                          ThreadRow,
                          $MemoryThreadTable,
                          ThreadSignalRow,
                          $ThreadSignalTable
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryThreadTableReferences
                              ._threadSignalRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryThreadTableReferences(
                                db,
                                table,
                                p0,
                              ).threadSignalRefs,
                          currentColumn: 'id',
                          referencedColumn: 'thread_id',
                          typedResults: items,
                        ),
                      if (signalLinkRefs)
                        await $_getPrefetchedDataByColumns<
                          ThreadRow,
                          $MemoryThreadTable,
                          LinkRow,
                          $SignalLinkTable
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryThreadTableReferences
                              ._signalLinkRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryThreadTableReferences(
                                db,
                                table,
                                p0,
                              ).signalLinkRefs,
                          currentColumn: 'id',
                          referencedColumn: 'thread_id',
                          typedResults: items,
                        ),
                      if (openLoopRefs)
                        await $_getPrefetchedDataByColumns<
                          ThreadRow,
                          $MemoryThreadTable,
                          OpenLoopRow,
                          $OpenLoopTable
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryThreadTableReferences
                              ._openLoopRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryThreadTableReferences(
                                db,
                                table,
                                p0,
                              ).openLoopRefs,
                          currentColumn: 'id',
                          referencedColumn: 'thread_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MemoryThreadTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $MemoryThreadTable,
      ThreadRow,
      $$MemoryThreadTableFilterComposer,
      $$MemoryThreadTableOrderingComposer,
      $$MemoryThreadTableAnnotationComposer,
      $$MemoryThreadTableCreateCompanionBuilder,
      $$MemoryThreadTableUpdateCompanionBuilder,
      (ThreadRow, $$MemoryThreadTableReferences),
      ThreadRow,
      PrefetchHooks Function({
        bool threadSignalRefs,
        bool signalLinkRefs,
        bool openLoopRefs,
      })
    >;
typedef $$ThreadSignalTableCreateCompanionBuilder =
    ThreadSignalCompanion Function({
      required int threadId,
      required int signalId,
      Value<int> rowid,
    });
typedef $$ThreadSignalTableUpdateCompanionBuilder =
    ThreadSignalCompanion Function({
      Value<int> threadId,
      Value<int> signalId,
      Value<int> rowid,
    });

final class $$ThreadSignalTableReferences
    extends
        BaseReferences<_$MemoryDatabase, $ThreadSignalTable, ThreadSignalRow> {
  $$ThreadSignalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryThreadTable _threadIdTable(_$MemoryDatabase db) =>
      db.memoryThread.createAlias('thread_signal__thread_id__thread__id');

  $$MemoryThreadTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<int>('thread_id')!;

    final manager = $$MemoryThreadTableTableManager(
      $_db,
      $_db.memoryThread,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalTable _signalIdTable(_$MemoryDatabase db) =>
      db.signal.createAlias('thread_signal__signal_id__signal__id');

  $$SignalTableProcessedTableManager get signalId {
    final $_column = $_itemColumn<int>('signal_id')!;

    final manager = $$SignalTableTableManager(
      $_db,
      $_db.signal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ThreadSignalTableFilterComposer
    extends Composer<_$MemoryDatabase, $ThreadSignalTable> {
  $$ThreadSignalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoryThreadTableFilterComposer get threadId {
    final $$MemoryThreadTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableFilterComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableFilterComposer get signalId {
    final $$SignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableFilterComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThreadSignalTableOrderingComposer
    extends Composer<_$MemoryDatabase, $ThreadSignalTable> {
  $$ThreadSignalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoryThreadTableOrderingComposer get threadId {
    final $$MemoryThreadTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableOrderingComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableOrderingComposer get signalId {
    final $$SignalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableOrderingComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThreadSignalTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $ThreadSignalTable> {
  $$ThreadSignalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MemoryThreadTableAnnotationComposer get threadId {
    final $$MemoryThreadTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableAnnotationComposer get signalId {
    final $$SignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableAnnotationComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ThreadSignalTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $ThreadSignalTable,
          ThreadSignalRow,
          $$ThreadSignalTableFilterComposer,
          $$ThreadSignalTableOrderingComposer,
          $$ThreadSignalTableAnnotationComposer,
          $$ThreadSignalTableCreateCompanionBuilder,
          $$ThreadSignalTableUpdateCompanionBuilder,
          (ThreadSignalRow, $$ThreadSignalTableReferences),
          ThreadSignalRow,
          PrefetchHooks Function({bool threadId, bool signalId})
        > {
  $$ThreadSignalTableTableManager(_$MemoryDatabase db, $ThreadSignalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThreadSignalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThreadSignalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThreadSignalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> threadId = const Value.absent(),
                Value<int> signalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThreadSignalCompanion(
                threadId: threadId,
                signalId: signalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int threadId,
                required int signalId,
                Value<int> rowid = const Value.absent(),
              }) => ThreadSignalCompanion.insert(
                threadId: threadId,
                signalId: signalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThreadSignalTable, ThreadSignalRow>(table),
                  $$ThreadSignalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false, signalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable: $$ThreadSignalTableReferences
                                    ._threadIdTable(db),
                                referencedColumn: $$ThreadSignalTableReferences
                                    ._threadIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (signalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.signalId,
                                referencedTable: $$ThreadSignalTableReferences
                                    ._signalIdTable(db),
                                referencedColumn: $$ThreadSignalTableReferences
                                    ._signalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ThreadSignalTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $ThreadSignalTable,
      ThreadSignalRow,
      $$ThreadSignalTableFilterComposer,
      $$ThreadSignalTableOrderingComposer,
      $$ThreadSignalTableAnnotationComposer,
      $$ThreadSignalTableCreateCompanionBuilder,
      $$ThreadSignalTableUpdateCompanionBuilder,
      (ThreadSignalRow, $$ThreadSignalTableReferences),
      ThreadSignalRow,
      PrefetchHooks Function({bool threadId, bool signalId})
    >;
typedef $$SignalLinkTableCreateCompanionBuilder =
    SignalLinkCompanion Function({
      Value<int> id,
      required int threadId,
      required int signalId,
      Value<String> reasonsJson,
      Value<double> score,
      Value<String> state,
      Value<String> decidedBy,
    });
typedef $$SignalLinkTableUpdateCompanionBuilder =
    SignalLinkCompanion Function({
      Value<int> id,
      Value<int> threadId,
      Value<int> signalId,
      Value<String> reasonsJson,
      Value<double> score,
      Value<String> state,
      Value<String> decidedBy,
    });

final class $$SignalLinkTableReferences
    extends BaseReferences<_$MemoryDatabase, $SignalLinkTable, LinkRow> {
  $$SignalLinkTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryThreadTable _threadIdTable(_$MemoryDatabase db) =>
      db.memoryThread.createAlias('link__thread_id__thread__id');

  $$MemoryThreadTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<int>('thread_id')!;

    final manager = $$MemoryThreadTableTableManager(
      $_db,
      $_db.memoryThread,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalTable _signalIdTable(_$MemoryDatabase db) =>
      db.signal.createAlias('link__signal_id__signal__id');

  $$SignalTableProcessedTableManager get signalId {
    final $_column = $_itemColumn<int>('signal_id')!;

    final manager = $$SignalTableTableManager(
      $_db,
      $_db.signal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SignalLinkTableFilterComposer
    extends Composer<_$MemoryDatabase, $SignalLinkTable> {
  $$SignalLinkTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonsJson => $composableBuilder(
    column: $table.reasonsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryThreadTableFilterComposer get threadId {
    final $$MemoryThreadTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableFilterComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableFilterComposer get signalId {
    final $$SignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableFilterComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalLinkTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SignalLinkTable> {
  $$SignalLinkTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonsJson => $composableBuilder(
    column: $table.reasonsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decidedBy => $composableBuilder(
    column: $table.decidedBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryThreadTableOrderingComposer get threadId {
    final $$MemoryThreadTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableOrderingComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableOrderingComposer get signalId {
    final $$SignalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableOrderingComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalLinkTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SignalLinkTable> {
  $$SignalLinkTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reasonsJson => $composableBuilder(
    column: $table.reasonsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get decidedBy =>
      $composableBuilder(column: $table.decidedBy, builder: (column) => column);

  $$MemoryThreadTableAnnotationComposer get threadId {
    final $$MemoryThreadTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableAnnotationComposer get signalId {
    final $$SignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableAnnotationComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SignalLinkTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SignalLinkTable,
          LinkRow,
          $$SignalLinkTableFilterComposer,
          $$SignalLinkTableOrderingComposer,
          $$SignalLinkTableAnnotationComposer,
          $$SignalLinkTableCreateCompanionBuilder,
          $$SignalLinkTableUpdateCompanionBuilder,
          (LinkRow, $$SignalLinkTableReferences),
          LinkRow,
          PrefetchHooks Function({bool threadId, bool signalId})
        > {
  $$SignalLinkTableTableManager(_$MemoryDatabase db, $SignalLinkTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignalLinkTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignalLinkTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignalLinkTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> threadId = const Value.absent(),
                Value<int> signalId = const Value.absent(),
                Value<String> reasonsJson = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> decidedBy = const Value.absent(),
              }) => SignalLinkCompanion(
                id: id,
                threadId: threadId,
                signalId: signalId,
                reasonsJson: reasonsJson,
                score: score,
                state: state,
                decidedBy: decidedBy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int threadId,
                required int signalId,
                Value<String> reasonsJson = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> decidedBy = const Value.absent(),
              }) => SignalLinkCompanion.insert(
                id: id,
                threadId: threadId,
                signalId: signalId,
                reasonsJson: reasonsJson,
                score: score,
                state: state,
                decidedBy: decidedBy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SignalLinkTable, LinkRow>(table),
                  $$SignalLinkTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false, signalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable: $$SignalLinkTableReferences
                                    ._threadIdTable(db),
                                referencedColumn: $$SignalLinkTableReferences
                                    ._threadIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (signalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.signalId,
                                referencedTable: $$SignalLinkTableReferences
                                    ._signalIdTable(db),
                                referencedColumn: $$SignalLinkTableReferences
                                    ._signalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SignalLinkTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SignalLinkTable,
      LinkRow,
      $$SignalLinkTableFilterComposer,
      $$SignalLinkTableOrderingComposer,
      $$SignalLinkTableAnnotationComposer,
      $$SignalLinkTableCreateCompanionBuilder,
      $$SignalLinkTableUpdateCompanionBuilder,
      (LinkRow, $$SignalLinkTableReferences),
      LinkRow,
      PrefetchHooks Function({bool threadId, bool signalId})
    >;
typedef $$OpenLoopTableCreateCompanionBuilder =
    OpenLoopCompanion Function({
      Value<int> id,
      required int threadId,
      Value<int?> intentId,
      required String owner,
      required String title,
      Value<int?> dueAt,
      Value<String> state,
      Value<String?> closedBy,
    });
typedef $$OpenLoopTableUpdateCompanionBuilder =
    OpenLoopCompanion Function({
      Value<int> id,
      Value<int> threadId,
      Value<int?> intentId,
      Value<String> owner,
      Value<String> title,
      Value<int?> dueAt,
      Value<String> state,
      Value<String?> closedBy,
    });

final class $$OpenLoopTableReferences
    extends BaseReferences<_$MemoryDatabase, $OpenLoopTable, OpenLoopRow> {
  $$OpenLoopTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemoryThreadTable _threadIdTable(_$MemoryDatabase db) =>
      db.memoryThread.createAlias('open_loop__thread_id__thread__id');

  $$MemoryThreadTableProcessedTableManager get threadId {
    final $_column = $_itemColumn<int>('thread_id')!;

    final manager = $$MemoryThreadTableTableManager(
      $_db,
      $_db.memoryThread,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_threadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OpenLoopTableFilterComposer
    extends Composer<_$MemoryDatabase, $OpenLoopTable> {
  $$OpenLoopTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentId => $composableBuilder(
    column: $table.intentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnFilters(column),
  );

  $$MemoryThreadTableFilterComposer get threadId {
    final $$MemoryThreadTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableFilterComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenLoopTableOrderingComposer
    extends Composer<_$MemoryDatabase, $OpenLoopTable> {
  $$OpenLoopTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentId => $composableBuilder(
    column: $table.intentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemoryThreadTableOrderingComposer get threadId {
    final $$MemoryThreadTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableOrderingComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenLoopTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $OpenLoopTable> {
  $$OpenLoopTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get intentId =>
      $composableBuilder(column: $table.intentId, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);

  $$MemoryThreadTableAnnotationComposer get threadId {
    final $$MemoryThreadTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.threadId,
      referencedTable: $db.memoryThread,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryThreadTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryThread,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenLoopTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $OpenLoopTable,
          OpenLoopRow,
          $$OpenLoopTableFilterComposer,
          $$OpenLoopTableOrderingComposer,
          $$OpenLoopTableAnnotationComposer,
          $$OpenLoopTableCreateCompanionBuilder,
          $$OpenLoopTableUpdateCompanionBuilder,
          (OpenLoopRow, $$OpenLoopTableReferences),
          OpenLoopRow,
          PrefetchHooks Function({bool threadId})
        > {
  $$OpenLoopTableTableManager(_$MemoryDatabase db, $OpenLoopTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpenLoopTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpenLoopTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpenLoopTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> threadId = const Value.absent(),
                Value<int?> intentId = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
              }) => OpenLoopCompanion(
                id: id,
                threadId: threadId,
                intentId: intentId,
                owner: owner,
                title: title,
                dueAt: dueAt,
                state: state,
                closedBy: closedBy,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int threadId,
                Value<int?> intentId = const Value.absent(),
                required String owner,
                required String title,
                Value<int?> dueAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
              }) => OpenLoopCompanion.insert(
                id: id,
                threadId: threadId,
                intentId: intentId,
                owner: owner,
                title: title,
                dueAt: dueAt,
                state: state,
                closedBy: closedBy,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpenLoopTable, OpenLoopRow>(table),
                  $$OpenLoopTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({threadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (threadId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.threadId,
                                referencedTable: $$OpenLoopTableReferences
                                    ._threadIdTable(db),
                                referencedColumn: $$OpenLoopTableReferences
                                    ._threadIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OpenLoopTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $OpenLoopTable,
      OpenLoopRow,
      $$OpenLoopTableFilterComposer,
      $$OpenLoopTableOrderingComposer,
      $$OpenLoopTableAnnotationComposer,
      $$OpenLoopTableCreateCompanionBuilder,
      $$OpenLoopTableUpdateCompanionBuilder,
      (OpenLoopRow, $$OpenLoopTableReferences),
      OpenLoopRow,
      PrefetchHooks Function({bool threadId})
    >;
typedef $$SeriesTableCreateCompanionBuilder =
    SeriesCompanion Function({
      Value<int> id,
      required String family,
      required String kind,
      required String counterpartKey,
      required String title,
      Value<String> cycleJson,
      Value<String> certainty,
      Value<double> strength,
      Value<String> decision,
      Value<bool> tracking,
      required int lastEventAt,
      Value<int?> nextFrom,
      Value<int?> nextTo,
      Value<String> state,
    });
typedef $$SeriesTableUpdateCompanionBuilder =
    SeriesCompanion Function({
      Value<int> id,
      Value<String> family,
      Value<String> kind,
      Value<String> counterpartKey,
      Value<String> title,
      Value<String> cycleJson,
      Value<String> certainty,
      Value<double> strength,
      Value<String> decision,
      Value<bool> tracking,
      Value<int> lastEventAt,
      Value<int?> nextFrom,
      Value<int?> nextTo,
      Value<String> state,
    });

final class $$SeriesTableReferences
    extends BaseReferences<_$MemoryDatabase, $SeriesTable, SeriesRow> {
  $$SeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeriesSignalTable, List<SeriesSignalRow>>
  _seriesSignalRefsTable(_$MemoryDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesSignal,
    aliasName: 'series__id__series_signal__series_id',
  );

  $$SeriesSignalTableProcessedTableManager get seriesSignalRefs {
    final manager = $$SeriesSignalTableTableManager(
      $_db,
      $_db.seriesSignal,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesSignalRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeriesTableFilterComposer
    extends Composer<_$MemoryDatabase, $SeriesTable> {
  $$SeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleJson => $composableBuilder(
    column: $table.cycleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certainty => $composableBuilder(
    column: $table.certainty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tracking => $composableBuilder(
    column: $table.tracking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastEventAt => $composableBuilder(
    column: $table.lastEventAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextFrom => $composableBuilder(
    column: $table.nextFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextTo => $composableBuilder(
    column: $table.nextTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seriesSignalRefs(
    Expression<bool> Function($$SeriesSignalTableFilterComposer f) f,
  ) {
    final $$SeriesSignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSignal,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSignalTableFilterComposer(
            $db: $db,
            $table: $db.seriesSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SeriesTable> {
  $$SeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleJson => $composableBuilder(
    column: $table.cycleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certainty => $composableBuilder(
    column: $table.certainty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tracking => $composableBuilder(
    column: $table.tracking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastEventAt => $composableBuilder(
    column: $table.lastEventAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextFrom => $composableBuilder(
    column: $table.nextFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextTo => $composableBuilder(
    column: $table.nextTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SeriesTable> {
  $$SeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cycleJson =>
      $composableBuilder(column: $table.cycleJson, builder: (column) => column);

  GeneratedColumn<String> get certainty =>
      $composableBuilder(column: $table.certainty, builder: (column) => column);

  GeneratedColumn<double> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<bool> get tracking =>
      $composableBuilder(column: $table.tracking, builder: (column) => column);

  GeneratedColumn<int> get lastEventAt => $composableBuilder(
    column: $table.lastEventAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextFrom =>
      $composableBuilder(column: $table.nextFrom, builder: (column) => column);

  GeneratedColumn<int> get nextTo =>
      $composableBuilder(column: $table.nextTo, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  Expression<T> seriesSignalRefs<T extends Object>(
    Expression<T> Function($$SeriesSignalTableAnnotationComposer a) f,
  ) {
    final $$SeriesSignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSignal,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSignalTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesSignal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SeriesTable,
          SeriesRow,
          $$SeriesTableFilterComposer,
          $$SeriesTableOrderingComposer,
          $$SeriesTableAnnotationComposer,
          $$SeriesTableCreateCompanionBuilder,
          $$SeriesTableUpdateCompanionBuilder,
          (SeriesRow, $$SeriesTableReferences),
          SeriesRow,
          PrefetchHooks Function({bool seriesSignalRefs})
        > {
  $$SeriesTableTableManager(_$MemoryDatabase db, $SeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> counterpartKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> cycleJson = const Value.absent(),
                Value<String> certainty = const Value.absent(),
                Value<double> strength = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<bool> tracking = const Value.absent(),
                Value<int> lastEventAt = const Value.absent(),
                Value<int?> nextFrom = const Value.absent(),
                Value<int?> nextTo = const Value.absent(),
                Value<String> state = const Value.absent(),
              }) => SeriesCompanion(
                id: id,
                family: family,
                kind: kind,
                counterpartKey: counterpartKey,
                title: title,
                cycleJson: cycleJson,
                certainty: certainty,
                strength: strength,
                decision: decision,
                tracking: tracking,
                lastEventAt: lastEventAt,
                nextFrom: nextFrom,
                nextTo: nextTo,
                state: state,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String family,
                required String kind,
                required String counterpartKey,
                required String title,
                Value<String> cycleJson = const Value.absent(),
                Value<String> certainty = const Value.absent(),
                Value<double> strength = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<bool> tracking = const Value.absent(),
                required int lastEventAt,
                Value<int?> nextFrom = const Value.absent(),
                Value<int?> nextTo = const Value.absent(),
                Value<String> state = const Value.absent(),
              }) => SeriesCompanion.insert(
                id: id,
                family: family,
                kind: kind,
                counterpartKey: counterpartKey,
                title: title,
                cycleJson: cycleJson,
                certainty: certainty,
                strength: strength,
                decision: decision,
                tracking: tracking,
                lastEventAt: lastEventAt,
                nextFrom: nextFrom,
                nextTo: nextTo,
                state: state,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesTable, SeriesRow>(table),
                  $$SeriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesSignalRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (seriesSignalRefs) db.seriesSignal],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seriesSignalRefs)
                    await $_getPrefetchedDataByColumns<
                      SeriesRow,
                      $SeriesTable,
                      SeriesSignalRow,
                      $SeriesSignalTable
                    >(
                      currentTable: table,
                      referencedTable: $$SeriesTableReferences
                          ._seriesSignalRefsTable(db),
                      managerFromTypedResult: (p0) => $$SeriesTableReferences(
                        db,
                        table,
                        p0,
                      ).seriesSignalRefs,
                      currentColumn: 'id',
                      referencedColumn: 'series_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SeriesTable,
      SeriesRow,
      $$SeriesTableFilterComposer,
      $$SeriesTableOrderingComposer,
      $$SeriesTableAnnotationComposer,
      $$SeriesTableCreateCompanionBuilder,
      $$SeriesTableUpdateCompanionBuilder,
      (SeriesRow, $$SeriesTableReferences),
      SeriesRow,
      PrefetchHooks Function({bool seriesSignalRefs})
    >;
typedef $$SeriesSignalTableCreateCompanionBuilder =
    SeriesSignalCompanion Function({
      required int seriesId,
      required int signalId,
      Value<int> rowid,
    });
typedef $$SeriesSignalTableUpdateCompanionBuilder =
    SeriesSignalCompanion Function({
      Value<int> seriesId,
      Value<int> signalId,
      Value<int> rowid,
    });

final class $$SeriesSignalTableReferences
    extends
        BaseReferences<_$MemoryDatabase, $SeriesSignalTable, SeriesSignalRow> {
  $$SeriesSignalTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeriesTable _seriesIdTable(_$MemoryDatabase db) =>
      db.series.createAlias('series_signal__series_id__series__id');

  $$SeriesTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<int>('series_id')!;

    final manager = $$SeriesTableTableManager(
      $_db,
      $_db.series,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SignalTable _signalIdTable(_$MemoryDatabase db) =>
      db.signal.createAlias('series_signal__signal_id__signal__id');

  $$SignalTableProcessedTableManager get signalId {
    final $_column = $_itemColumn<int>('signal_id')!;

    final manager = $$SignalTableTableManager(
      $_db,
      $_db.signal,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesSignalTableFilterComposer
    extends Composer<_$MemoryDatabase, $SeriesSignalTable> {
  $$SeriesSignalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeriesTableFilterComposer get seriesId {
    final $$SeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableFilterComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableFilterComposer get signalId {
    final $$SignalTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableFilterComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSignalTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SeriesSignalTable> {
  $$SeriesSignalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeriesTableOrderingComposer get seriesId {
    final $$SeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableOrderingComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableOrderingComposer get signalId {
    final $$SignalTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableOrderingComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSignalTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SeriesSignalTable> {
  $$SeriesSignalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeriesTableAnnotationComposer get seriesId {
    final $$SeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SignalTableAnnotationComposer get signalId {
    final $$SignalTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signalId,
      referencedTable: $db.signal,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SignalTableAnnotationComposer(
            $db: $db,
            $table: $db.signal,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSignalTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SeriesSignalTable,
          SeriesSignalRow,
          $$SeriesSignalTableFilterComposer,
          $$SeriesSignalTableOrderingComposer,
          $$SeriesSignalTableAnnotationComposer,
          $$SeriesSignalTableCreateCompanionBuilder,
          $$SeriesSignalTableUpdateCompanionBuilder,
          (SeriesSignalRow, $$SeriesSignalTableReferences),
          SeriesSignalRow,
          PrefetchHooks Function({bool seriesId, bool signalId})
        > {
  $$SeriesSignalTableTableManager(_$MemoryDatabase db, $SeriesSignalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesSignalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesSignalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesSignalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seriesId = const Value.absent(),
                Value<int> signalId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesSignalCompanion(
                seriesId: seriesId,
                signalId: signalId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seriesId,
                required int signalId,
                Value<int> rowid = const Value.absent(),
              }) => SeriesSignalCompanion.insert(
                seriesId: seriesId,
                signalId: signalId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesSignalTable, SeriesSignalRow>(table),
                  $$SeriesSignalTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, signalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seriesId,
                                referencedTable: $$SeriesSignalTableReferences
                                    ._seriesIdTable(db),
                                referencedColumn: $$SeriesSignalTableReferences
                                    ._seriesIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (signalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.signalId,
                                referencedTable: $$SeriesSignalTableReferences
                                    ._signalIdTable(db),
                                referencedColumn: $$SeriesSignalTableReferences
                                    ._signalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SeriesSignalTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SeriesSignalTable,
      SeriesSignalRow,
      $$SeriesSignalTableFilterComposer,
      $$SeriesSignalTableOrderingComposer,
      $$SeriesSignalTableAnnotationComposer,
      $$SeriesSignalTableCreateCompanionBuilder,
      $$SeriesSignalTableUpdateCompanionBuilder,
      (SeriesSignalRow, $$SeriesSignalTableReferences),
      SeriesSignalRow,
      PrefetchHooks Function({bool seriesId, bool signalId})
    >;
typedef $$FeedbackTableCreateCompanionBuilder =
    FeedbackCompanion Function({
      Value<int> id,
      required String targetType,
      required int targetId,
      required String action,
      required int at,
    });
typedef $$FeedbackTableUpdateCompanionBuilder =
    FeedbackCompanion Function({
      Value<int> id,
      Value<String> targetType,
      Value<int> targetId,
      Value<String> action,
      Value<int> at,
    });

class $$FeedbackTableFilterComposer
    extends Composer<_$MemoryDatabase, $FeedbackTable> {
  $$FeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedbackTableOrderingComposer
    extends Composer<_$MemoryDatabase, $FeedbackTable> {
  $$FeedbackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedbackTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $FeedbackTable> {
  $$FeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$FeedbackTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $FeedbackTable,
          FeedbackRow,
          $$FeedbackTableFilterComposer,
          $$FeedbackTableOrderingComposer,
          $$FeedbackTableAnnotationComposer,
          $$FeedbackTableCreateCompanionBuilder,
          $$FeedbackTableUpdateCompanionBuilder,
          (
            FeedbackRow,
            BaseReferences<_$MemoryDatabase, $FeedbackTable, FeedbackRow>,
          ),
          FeedbackRow,
          PrefetchHooks Function()
        > {
  $$FeedbackTableTableManager(_$MemoryDatabase db, $FeedbackTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedbackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int> targetId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int> at = const Value.absent(),
              }) => FeedbackCompanion(
                id: id,
                targetType: targetType,
                targetId: targetId,
                action: action,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetType,
                required int targetId,
                required String action,
                required int at,
              }) => FeedbackCompanion.insert(
                id: id,
                targetType: targetType,
                targetId: targetId,
                action: action,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedbackTable, FeedbackRow>(table),
                  BaseReferences<_$MemoryDatabase, $FeedbackTable, FeedbackRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $FeedbackTable,
      FeedbackRow,
      $$FeedbackTableFilterComposer,
      $$FeedbackTableOrderingComposer,
      $$FeedbackTableAnnotationComposer,
      $$FeedbackTableCreateCompanionBuilder,
      $$FeedbackTableUpdateCompanionBuilder,
      (
        FeedbackRow,
        BaseReferences<_$MemoryDatabase, $FeedbackTable, FeedbackRow>,
      ),
      FeedbackRow,
      PrefetchHooks Function()
    >;
typedef $$SuppressRuleTableCreateCompanionBuilder =
    SuppressRuleCompanion Function({
      Value<int> id,
      required String family,
      required String kind,
      Value<String?> counterpartKey,
      Value<String> reason,
    });
typedef $$SuppressRuleTableUpdateCompanionBuilder =
    SuppressRuleCompanion Function({
      Value<int> id,
      Value<String> family,
      Value<String> kind,
      Value<String?> counterpartKey,
      Value<String> reason,
    });

class $$SuppressRuleTableFilterComposer
    extends Composer<_$MemoryDatabase, $SuppressRuleTable> {
  $$SuppressRuleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppressRuleTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SuppressRuleTable> {
  $$SuppressRuleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppressRuleTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SuppressRuleTable> {
  $$SuppressRuleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get counterpartKey => $composableBuilder(
    column: $table.counterpartKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$SuppressRuleTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SuppressRuleTable,
          SuppressRuleRow,
          $$SuppressRuleTableFilterComposer,
          $$SuppressRuleTableOrderingComposer,
          $$SuppressRuleTableAnnotationComposer,
          $$SuppressRuleTableCreateCompanionBuilder,
          $$SuppressRuleTableUpdateCompanionBuilder,
          (
            SuppressRuleRow,
            BaseReferences<
              _$MemoryDatabase,
              $SuppressRuleTable,
              SuppressRuleRow
            >,
          ),
          SuppressRuleRow,
          PrefetchHooks Function()
        > {
  $$SuppressRuleTableTableManager(_$MemoryDatabase db, $SuppressRuleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppressRuleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppressRuleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppressRuleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> counterpartKey = const Value.absent(),
                Value<String> reason = const Value.absent(),
              }) => SuppressRuleCompanion(
                id: id,
                family: family,
                kind: kind,
                counterpartKey: counterpartKey,
                reason: reason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String family,
                required String kind,
                Value<String?> counterpartKey = const Value.absent(),
                Value<String> reason = const Value.absent(),
              }) => SuppressRuleCompanion.insert(
                id: id,
                family: family,
                kind: kind,
                counterpartKey: counterpartKey,
                reason: reason,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppressRuleTable, SuppressRuleRow>(table),
                  BaseReferences<
                    _$MemoryDatabase,
                    $SuppressRuleTable,
                    SuppressRuleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppressRuleTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SuppressRuleTable,
      SuppressRuleRow,
      $$SuppressRuleTableFilterComposer,
      $$SuppressRuleTableOrderingComposer,
      $$SuppressRuleTableAnnotationComposer,
      $$SuppressRuleTableCreateCompanionBuilder,
      $$SuppressRuleTableUpdateCompanionBuilder,
      (
        SuppressRuleRow,
        BaseReferences<_$MemoryDatabase, $SuppressRuleTable, SuppressRuleRow>,
      ),
      SuppressRuleRow,
      PrefetchHooks Function()
    >;
typedef $$AppRuleTableCreateCompanionBuilder =
    AppRuleCompanion Function({
      required String pkg,
      Value<String> appClass,
      Value<String> keepPolicy,
      Value<bool> userSet,
      Value<int> rowid,
    });
typedef $$AppRuleTableUpdateCompanionBuilder =
    AppRuleCompanion Function({
      Value<String> pkg,
      Value<String> appClass,
      Value<String> keepPolicy,
      Value<bool> userSet,
      Value<int> rowid,
    });

class $$AppRuleTableFilterComposer
    extends Composer<_$MemoryDatabase, $AppRuleTable> {
  $$AppRuleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appClass => $composableBuilder(
    column: $table.appClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keepPolicy => $composableBuilder(
    column: $table.keepPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userSet => $composableBuilder(
    column: $table.userSet,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppRuleTableOrderingComposer
    extends Composer<_$MemoryDatabase, $AppRuleTable> {
  $$AppRuleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appClass => $composableBuilder(
    column: $table.appClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keepPolicy => $composableBuilder(
    column: $table.keepPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userSet => $composableBuilder(
    column: $table.userSet,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppRuleTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $AppRuleTable> {
  $$AppRuleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pkg =>
      $composableBuilder(column: $table.pkg, builder: (column) => column);

  GeneratedColumn<String> get appClass =>
      $composableBuilder(column: $table.appClass, builder: (column) => column);

  GeneratedColumn<String> get keepPolicy => $composableBuilder(
    column: $table.keepPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userSet =>
      $composableBuilder(column: $table.userSet, builder: (column) => column);
}

class $$AppRuleTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $AppRuleTable,
          AppRuleRow,
          $$AppRuleTableFilterComposer,
          $$AppRuleTableOrderingComposer,
          $$AppRuleTableAnnotationComposer,
          $$AppRuleTableCreateCompanionBuilder,
          $$AppRuleTableUpdateCompanionBuilder,
          (
            AppRuleRow,
            BaseReferences<_$MemoryDatabase, $AppRuleTable, AppRuleRow>,
          ),
          AppRuleRow,
          PrefetchHooks Function()
        > {
  $$AppRuleTableTableManager(_$MemoryDatabase db, $AppRuleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppRuleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppRuleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppRuleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pkg = const Value.absent(),
                Value<String> appClass = const Value.absent(),
                Value<String> keepPolicy = const Value.absent(),
                Value<bool> userSet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppRuleCompanion(
                pkg: pkg,
                appClass: appClass,
                keepPolicy: keepPolicy,
                userSet: userSet,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pkg,
                Value<String> appClass = const Value.absent(),
                Value<String> keepPolicy = const Value.absent(),
                Value<bool> userSet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppRuleCompanion.insert(
                pkg: pkg,
                appClass: appClass,
                keepPolicy: keepPolicy,
                userSet: userSet,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppRuleTable, AppRuleRow>(table),
                  BaseReferences<_$MemoryDatabase, $AppRuleTable, AppRuleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppRuleTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $AppRuleTable,
      AppRuleRow,
      $$AppRuleTableFilterComposer,
      $$AppRuleTableOrderingComposer,
      $$AppRuleTableAnnotationComposer,
      $$AppRuleTableCreateCompanionBuilder,
      $$AppRuleTableUpdateCompanionBuilder,
      (AppRuleRow, BaseReferences<_$MemoryDatabase, $AppRuleTable, AppRuleRow>),
      AppRuleRow,
      PrefetchHooks Function()
    >;
typedef $$ChannelScoreTableCreateCompanionBuilder =
    ChannelScoreCompanion Function({
      required String pkg,
      required String channel,
      Value<int> score,
      Value<int> rowid,
    });
typedef $$ChannelScoreTableUpdateCompanionBuilder =
    ChannelScoreCompanion Function({
      Value<String> pkg,
      Value<String> channel,
      Value<int> score,
      Value<int> rowid,
    });

class $$ChannelScoreTableFilterComposer
    extends Composer<_$MemoryDatabase, $ChannelScoreTable> {
  $$ChannelScoreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelScoreTableOrderingComposer
    extends Composer<_$MemoryDatabase, $ChannelScoreTable> {
  $$ChannelScoreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pkg => $composableBuilder(
    column: $table.pkg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelScoreTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $ChannelScoreTable> {
  $$ChannelScoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pkg =>
      $composableBuilder(column: $table.pkg, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);
}

class $$ChannelScoreTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $ChannelScoreTable,
          ChannelScoreRow,
          $$ChannelScoreTableFilterComposer,
          $$ChannelScoreTableOrderingComposer,
          $$ChannelScoreTableAnnotationComposer,
          $$ChannelScoreTableCreateCompanionBuilder,
          $$ChannelScoreTableUpdateCompanionBuilder,
          (
            ChannelScoreRow,
            BaseReferences<
              _$MemoryDatabase,
              $ChannelScoreTable,
              ChannelScoreRow
            >,
          ),
          ChannelScoreRow,
          PrefetchHooks Function()
        > {
  $$ChannelScoreTableTableManager(_$MemoryDatabase db, $ChannelScoreTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelScoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelScoreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelScoreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pkg = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelScoreCompanion(
                pkg: pkg,
                channel: channel,
                score: score,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pkg,
                required String channel,
                Value<int> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelScoreCompanion.insert(
                pkg: pkg,
                channel: channel,
                score: score,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelScoreTable, ChannelScoreRow>(table),
                  BaseReferences<
                    _$MemoryDatabase,
                    $ChannelScoreTable,
                    ChannelScoreRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelScoreTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $ChannelScoreTable,
      ChannelScoreRow,
      $$ChannelScoreTableFilterComposer,
      $$ChannelScoreTableOrderingComposer,
      $$ChannelScoreTableAnnotationComposer,
      $$ChannelScoreTableCreateCompanionBuilder,
      $$ChannelScoreTableUpdateCompanionBuilder,
      (
        ChannelScoreRow,
        BaseReferences<_$MemoryDatabase, $ChannelScoreTable, ChannelScoreRow>,
      ),
      ChannelScoreRow,
      PrefetchHooks Function()
    >;
typedef $$SettingTableCreateCompanionBuilder =
    SettingCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingTableUpdateCompanionBuilder =
    SettingCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingTableFilterComposer
    extends Composer<_$MemoryDatabase, $SettingTable> {
  $$SettingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingTableOrderingComposer
    extends Composer<_$MemoryDatabase, $SettingTable> {
  $$SettingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $SettingTable> {
  $$SettingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $SettingTable,
          SettingRow,
          $$SettingTableFilterComposer,
          $$SettingTableOrderingComposer,
          $$SettingTableAnnotationComposer,
          $$SettingTableCreateCompanionBuilder,
          $$SettingTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$MemoryDatabase, $SettingTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingTableTableManager(_$MemoryDatabase db, $SettingTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingTable, SettingRow>(table),
                  BaseReferences<_$MemoryDatabase, $SettingTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $SettingTable,
      SettingRow,
      $$SettingTableFilterComposer,
      $$SettingTableOrderingComposer,
      $$SettingTableAnnotationComposer,
      $$SettingTableCreateCompanionBuilder,
      $$SettingTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$MemoryDatabase, $SettingTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$DaySummaryTableCreateCompanionBuilder =
    DaySummaryCompanion Function({
      required String date,
      Value<String> headline,
      Value<String> factsJson,
      Value<int> setAsideCount,
      Value<int> rowid,
    });
typedef $$DaySummaryTableUpdateCompanionBuilder =
    DaySummaryCompanion Function({
      Value<String> date,
      Value<String> headline,
      Value<String> factsJson,
      Value<int> setAsideCount,
      Value<int> rowid,
    });

class $$DaySummaryTableFilterComposer
    extends Composer<_$MemoryDatabase, $DaySummaryTable> {
  $$DaySummaryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headline => $composableBuilder(
    column: $table.headline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factsJson => $composableBuilder(
    column: $table.factsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setAsideCount => $composableBuilder(
    column: $table.setAsideCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DaySummaryTableOrderingComposer
    extends Composer<_$MemoryDatabase, $DaySummaryTable> {
  $$DaySummaryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headline => $composableBuilder(
    column: $table.headline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factsJson => $composableBuilder(
    column: $table.factsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setAsideCount => $composableBuilder(
    column: $table.setAsideCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaySummaryTableAnnotationComposer
    extends Composer<_$MemoryDatabase, $DaySummaryTable> {
  $$DaySummaryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get headline =>
      $composableBuilder(column: $table.headline, builder: (column) => column);

  GeneratedColumn<String> get factsJson =>
      $composableBuilder(column: $table.factsJson, builder: (column) => column);

  GeneratedColumn<int> get setAsideCount => $composableBuilder(
    column: $table.setAsideCount,
    builder: (column) => column,
  );
}

class $$DaySummaryTableTableManager
    extends
        RootTableManager<
          _$MemoryDatabase,
          $DaySummaryTable,
          DayRow,
          $$DaySummaryTableFilterComposer,
          $$DaySummaryTableOrderingComposer,
          $$DaySummaryTableAnnotationComposer,
          $$DaySummaryTableCreateCompanionBuilder,
          $$DaySummaryTableUpdateCompanionBuilder,
          (DayRow, BaseReferences<_$MemoryDatabase, $DaySummaryTable, DayRow>),
          DayRow,
          PrefetchHooks Function()
        > {
  $$DaySummaryTableTableManager(_$MemoryDatabase db, $DaySummaryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaySummaryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaySummaryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaySummaryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> headline = const Value.absent(),
                Value<String> factsJson = const Value.absent(),
                Value<int> setAsideCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySummaryCompanion(
                date: date,
                headline: headline,
                factsJson: factsJson,
                setAsideCount: setAsideCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<String> headline = const Value.absent(),
                Value<String> factsJson = const Value.absent(),
                Value<int> setAsideCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaySummaryCompanion.insert(
                date: date,
                headline: headline,
                factsJson: factsJson,
                setAsideCount: setAsideCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DaySummaryTable, DayRow>(table),
                  BaseReferences<_$MemoryDatabase, $DaySummaryTable, DayRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DaySummaryTableProcessedTableManager =
    ProcessedTableManager<
      _$MemoryDatabase,
      $DaySummaryTable,
      DayRow,
      $$DaySummaryTableFilterComposer,
      $$DaySummaryTableOrderingComposer,
      $$DaySummaryTableAnnotationComposer,
      $$DaySummaryTableCreateCompanionBuilder,
      $$DaySummaryTableUpdateCompanionBuilder,
      (DayRow, BaseReferences<_$MemoryDatabase, $DaySummaryTable, DayRow>),
      DayRow,
      PrefetchHooks Function()
    >;

class $MemoryDatabaseManager {
  final _$MemoryDatabase _db;
  $MemoryDatabaseManager(this._db);
  $$SignalTableTableManager get signal =>
      $$SignalTableTableManager(_db, _db.signal);
  $$PersonTableTableManager get person =>
      $$PersonTableTableManager(_db, _db.person);
  $$PersonHandleTableTableManager get personHandle =>
      $$PersonHandleTableTableManager(_db, _db.personHandle);
  $$EntityTableTableManager get entity =>
      $$EntityTableTableManager(_db, _db.entity);
  $$SignalEntityTableTableManager get signalEntity =>
      $$SignalEntityTableTableManager(_db, _db.signalEntity);
  $$SignalIntentTableTableManager get signalIntent =>
      $$SignalIntentTableTableManager(_db, _db.signalIntent);
  $$MemoryThreadTableTableManager get memoryThread =>
      $$MemoryThreadTableTableManager(_db, _db.memoryThread);
  $$ThreadSignalTableTableManager get threadSignal =>
      $$ThreadSignalTableTableManager(_db, _db.threadSignal);
  $$SignalLinkTableTableManager get signalLink =>
      $$SignalLinkTableTableManager(_db, _db.signalLink);
  $$OpenLoopTableTableManager get openLoop =>
      $$OpenLoopTableTableManager(_db, _db.openLoop);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$SeriesSignalTableTableManager get seriesSignal =>
      $$SeriesSignalTableTableManager(_db, _db.seriesSignal);
  $$FeedbackTableTableManager get feedback =>
      $$FeedbackTableTableManager(_db, _db.feedback);
  $$SuppressRuleTableTableManager get suppressRule =>
      $$SuppressRuleTableTableManager(_db, _db.suppressRule);
  $$AppRuleTableTableManager get appRule =>
      $$AppRuleTableTableManager(_db, _db.appRule);
  $$ChannelScoreTableTableManager get channelScore =>
      $$ChannelScoreTableTableManager(_db, _db.channelScore);
  $$SettingTableTableManager get setting =>
      $$SettingTableTableManager(_db, _db.setting);
  $$DaySummaryTableTableManager get daySummary =>
      $$DaySummaryTableTableManager(_db, _db.daySummary);
}
