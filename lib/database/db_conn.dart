import 'dart:io';

import 'package:modoemaniera/models/counters.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List<Counter> basicCounters = [
  Counter(0, 'Maniera', []),
  Counter(1, 'Modo e Maniera', []),
  Counter(2, 'Modo e Maniera Tale', []),
  Counter(3, 'Databeees', []),
];

Database db;

class CounterTable {
  static const tName = 'counters';
  static const id = 'id';
  static const name = 'name';
}

class HistoryTable {
  static const tName = 'history';
  static const id = 'id';
  static const counterId = 'counterId';
  static const date = 'date';
}

class DatabaseCreator {
  static bool isConnected = false;
  static const dbName = 'modoemaniera_database.db';
  static const countersColumnId = 'counters';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult]) {
    print(functionName);
    print(sql);
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createTables(Database db) async {
    final countersSql = '''
    CREATE TABLE ${CounterTable.tName}
    (
      ${CounterTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CounterTable.name} TEXT
    )
    ''';
    await db.execute(countersSql);
    final historySql = '''
    CREATE TABLE ${HistoryTable.tName}
    (
      ${HistoryTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${HistoryTable.counterId} INTEGER,
      ${HistoryTable.date} TEXT,
      FOREIGN KEY (${HistoryTable.counterId}) REFERENCES ${CounterTable.tName} (${CounterTable.id})
    )
    ''';
    await db.execute(historySql);
    final manieraSql = '''
    INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Maniera"
    )
    ''';
    await db.execute(manieraSql);
    final modoemanieraSql = '''
    INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Modo e maniera"
    )
    ''';
    await db.execute(modoemanieraSql);
    final modoemanierataleSql = '''
    INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Modo e maniera tale"
    )
    ''';
    await db.execute(modoemanierataleSql);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
      // await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath(dbName);
    openDatabase(path, version: 2, onCreate: _onCreate).then((_db) {
      db = _db;
      print(db);
      isConnected = true;
    });
  }

  Future<void> _onCreate(Database db, int version) async {
    await createTables(db);
  }

  Future<void> deleteDatabase() async => databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'modoemaniera_database.db'));
}

class RepositoryServiceCounters {
  static Future<List<Counter>> getAllCounters() async {
    final counterSql = '''SELECT * FROM ${CounterTable.tName}''';
    final dataCounters = await db.rawQuery(counterSql);
    final historySql = '''SELECT * FROM ${HistoryTable.tName}''';
    final dataHistory = await db.rawQuery(historySql);

    counters = List.generate(dataCounters.length, (i) {
      return Counter(
        dataCounters[i]['id'],
        dataCounters[i]['name'],
        dataHistory
            .where((dh) => dh['counterId'] == dataCounters[i]['id'])
            .map((dh) => DateTime.parse(dh['date']))
            .toList(),
      );
    });

    return counters;
  }

  static Future<void> addCounter(Counter counter) async {
    final sql = '''INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "${counter.name}"
    )''';
    final result = await db.rawInsert(sql);
    DatabaseCreator.databaseLog('Add Counter', sql, null, result);

    counters.add(counter);
  }

  static Future<void> deleteCounter(Counter counter) async {
    final sql = '''DELETE FROM ${CounterTable.tName}
    WHERE id = ${counter.id}
    ''';
    final result = await db.rawDelete(sql);
    DatabaseCreator.databaseLog('Delete Counter', sql, null, result);

    counters.remove(counter);
  }

  static Future<void> updateCounter(Counter counter) async {
    final sql = '''UPDATE ${CounterTable.tName}
    SET ${CounterTable.name} = "${counter.name}"
    WHERE id = ${counter.id}
    ''';
    final result = await db.rawUpdate(sql);
    DatabaseCreator.databaseLog('Update Counter', sql, null, result);

    final oldCounter = counters.firstWhere((c) {
      return c.id == counter.id;
    });
    final index = counters.indexOf(oldCounter);
    counters.remove(counter);
    counters.insert(index, counter);
  }
}

class RepositoryServiceHistory {
  static Future<void> addDate(DateTime date, int counterId) async {
    final sql = '''
    INSERT INTO ${HistoryTable.tName}
    (
      ${HistoryTable.date},
      ${HistoryTable.counterId}
    )
    VALUES
    (
      "${date.toString()}",
      "$counterId"
    )
    ''';
    final result = await db.rawInsert(sql);
    DatabaseCreator.databaseLog('Add Date History', sql, null, result);
  }

  static Future<void> removeLastDate(int counterId) async {
    final maxSql = '''
    SELECT MAX(${HistoryTable.id})
      FROM ${HistoryTable.tName}
      WHERE ${HistoryTable.counterId} = $counterId
    ''';
    final max = (await db.rawQuery(maxSql)).first['MAX(id)'];

    final sql = '''
    DELETE FROM ${HistoryTable.tName}
    WHERE ${HistoryTable.id} = $max
    ''';
    final result = await db.rawDelete(sql);
    DatabaseCreator.databaseLog('Remove last Date History', sql, null, result);
  }
}
