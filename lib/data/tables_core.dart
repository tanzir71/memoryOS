import 'package:drift/drift.dart';

@TableIndex(name: 'idx_signal_occurred_at', columns: {#occurredAt})
@TableIndex(name: 'idx_signal_sbn_key', columns: {#sbnKey})
@DataClassName('SignalRow')
class Signal extends Table {
  @override
  String get tableName => 'signal';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get inboxId => integer().nullable()();
  TextColumn get source => text()();
  TextColumn get pkg => text().withDefault(const Constant(''))();
  TextColumn get kind => text().withDefault(const Constant(''))();
  TextColumn get sbnKey => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get occurredAt => integer()();
  IntColumn get endedAt => integer().nullable()();
  IntColumn get personId => integer().nullable()();
  TextColumn get signalClass => text().named('class').withDefault(const Constant('system'))();
  BoolColumn get kept => boolean().withDefault(const Constant(true))();
  BoolColumn get redacted => boolean().withDefault(const Constant(false))();
  TextColumn get extrasJson => text().withDefault(const Constant('{}'))();
  IntColumn get deletedAt => integer().nullable()();
}

@DataClassName('PersonRow')
class Person extends Table {
  @override
  String get tableName => 'person';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text()();
  TextColumn get contactLookupKey => text().nullable()();
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();
}

@DataClassName('PersonHandleRow')
class PersonHandle extends Table {
  @override
  String get tableName => 'person_handle';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(Person, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get value => text()();
  TextColumn get app => text().withDefault(const Constant(''))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {type, value},
  ];
}

@DataClassName('EntityRow')
class Entity extends Table {
  @override
  String get tableName => 'entity';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get canonicalValue => text()();
  TextColumn get display => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {type, canonicalValue},
  ];
}

@DataClassName('SignalEntityRow')
class SignalEntity extends Table {
  @override
  String get tableName => 'signal_entity';

  IntColumn get signalId => integer().references(Signal, #id, onDelete: KeyAction.cascade)();
  IntColumn get entityId => integer().references(Entity, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().withDefault(const Constant('mention'))();

  @override
  Set<Column<Object>> get primaryKey => {signalId, entityId, role};
}

@DataClassName('IntentRow')
class SignalIntent extends Table {
  @override
  String get tableName => 'intent';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get signalId => integer().references(Signal, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get content => text().named('text')();
  IntColumn get dueAt => integer().nullable()();
  RealColumn get confidence => real().withDefault(const Constant(0.4))();
}
