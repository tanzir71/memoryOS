import 'package:drift/drift.dart';
import 'tables_core.dart';

@TableIndex(name: 'idx_thread_last_at', columns: {#lastAt})
@DataClassName('ThreadRow')
class MemoryThread extends Table {
  @override
  String get tableName => 'thread';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get kind => text().withDefault(const Constant('other'))();
  IntColumn get personId => integer().nullable()();
  IntColumn get startedAt => integer()();
  IntColumn get lastAt => integer()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  BoolColumn get userEdited => boolean().withDefault(const Constant(false))();
}

@DataClassName('ThreadSignalRow')
class ThreadSignal extends Table {
  @override
  String get tableName => 'thread_signal';

  IntColumn get threadId => integer().references(MemoryThread, #id, onDelete: KeyAction.cascade)();
  IntColumn get signalId => integer().references(Signal, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {threadId, signalId};
}

@DataClassName('LinkRow')
class SignalLink extends Table {
  @override
  String get tableName => 'link';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get threadId => integer().references(MemoryThread, #id, onDelete: KeyAction.cascade)();
  IntColumn get signalId => integer().references(Signal, #id, onDelete: KeyAction.cascade)();
  TextColumn get reasonsJson => text().withDefault(const Constant('[]'))();
  RealColumn get score => real().withDefault(const Constant(0.0))();
  TextColumn get state => text().withDefault(const Constant('linked'))();
  TextColumn get decidedBy => text().withDefault(const Constant('rule'))();
}

@TableIndex(name: 'idx_open_loop_due_at', columns: {#dueAt})
@DataClassName('OpenLoopRow')
class OpenLoop extends Table {
  @override
  String get tableName => 'open_loop';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get threadId => integer().references(MemoryThread, #id, onDelete: KeyAction.cascade)();
  IntColumn get intentId => integer().nullable()();
  TextColumn get owner => text()();
  TextColumn get title => text()();
  IntColumn get dueAt => integer().nullable()();
  TextColumn get state => text().withDefault(const Constant('open'))();
  TextColumn get closedBy => text().nullable()();
}

@TableIndex(name: 'idx_series_next_from', columns: {#nextFrom})
@DataClassName('SeriesRow')
class Series extends Table {
  @override
  String get tableName => 'series';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get family => text()();
  TextColumn get kind => text()();
  TextColumn get counterpartKey => text()();
  TextColumn get title => text()();
  TextColumn get cycleJson => text().withDefault(const Constant('{}'))();
  TextColumn get certainty => text().withDefault(const Constant('guess'))();
  RealColumn get strength => real().withDefault(const Constant(0.0))();
  TextColumn get decision => text().withDefault(const Constant('undecided'))();
  BoolColumn get tracking => boolean().withDefault(const Constant(true))();
  IntColumn get lastEventAt => integer()();
  IntColumn get nextFrom => integer().nullable()();
  IntColumn get nextTo => integer().nullable()();
  TextColumn get state => text().withDefault(const Constant('expected'))();
}

@DataClassName('SeriesSignalRow')
class SeriesSignal extends Table {
  @override
  String get tableName => 'series_signal';

  IntColumn get seriesId => integer().references(Series, #id, onDelete: KeyAction.cascade)();
  IntColumn get signalId => integer().references(Signal, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {seriesId, signalId};
}

@TableIndex(name: 'idx_feedback_at', columns: {#at})
@DataClassName('FeedbackRow')
class Feedback extends Table {
  @override
  String get tableName => 'feedback';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetType => text()();
  IntColumn get targetId => integer()();
  TextColumn get action => text()();
  IntColumn get at => integer()();
}

@DataClassName('SuppressRuleRow')
class SuppressRule extends Table {
  @override
  String get tableName => 'suppress_rule';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get family => text()();
  TextColumn get kind => text()();
  TextColumn get counterpartKey => text().nullable()();
  TextColumn get reason => text().withDefault(const Constant('user_drop'))();
}

@DataClassName('AppRuleRow')
class AppRule extends Table {
  @override
  String get tableName => 'app_rule';

  TextColumn get pkg => text()();
  TextColumn get appClass => text().named('class').withDefault(const Constant('system'))();
  TextColumn get keepPolicy => text().withDefault(const Constant('default'))();
  BoolColumn get userSet => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {pkg};
}

@DataClassName('ChannelScoreRow')
class ChannelScore extends Table {
  @override
  String get tableName => 'channel_score';

  TextColumn get pkg => text()();
  TextColumn get channel => text()();
  IntColumn get score => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {pkg, channel};
}

@DataClassName('SettingRow')
class Setting extends Table {
  @override
  String get tableName => 'setting';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('DayRow')
class DaySummary extends Table {
  @override
  String get tableName => 'day';

  TextColumn get date => text()();
  TextColumn get headline => text().withDefault(const Constant(''))();
  TextColumn get factsJson => text().withDefault(const Constant('{}'))();
  IntColumn get setAsideCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {date};
}
