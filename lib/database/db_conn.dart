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

  Future<void> createCountersTable(Database db) async {
    final countersSql = '''
    CREATE TABLE ${CounterTable.tName}
    (
      ${CounterTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CounterTable.name} TEXT
    );
    CREATE TABLE ${HistoryTable.tName}
    (
      ${HistoryTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      FOREIGN KEY(${HistoryTable.counterId}) REFERENCES ${CounterTable.tName}(${CounterTable.id})
      ${HistoryTable.date} TEXT,
    );
    INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Maniera"
    )
    INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Modo e maniera"
    )INSERT INTO ${CounterTable.tName}
    (
      ${CounterTable.name}
    )
    VALUES
    (
      "Modo e maniera tale"
    )
    ''';

    await db.execute(countersSql);
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
    await createCountersTable(db);
  }
}

class RepositoryServiceCounters {
  static Future<List<Counter>> getAllCounters() async {
    final sql = '''SELECT * FROM ${CounterTable.tName}''';
    final data = await db.rawQuery(sql);

    counters = List.generate(data.length, (i) {
      return Counter(
        data[i]['id'],
        data[i]['name'],
        [DateTime.now()],
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
    final sql = '''INSERT INTO ${HistoryTable.tName}
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

    Counter _c = counters.firstWhere((c) {
      return c.id == counterId;
    });
    int index = counters.indexOf(_c);
    counters[index].dateHistory.add(date);
  }
}

Future<void> deleteDatabase() async => databaseFactory
    .deleteDatabase(join(await getDatabasesPath(), 'modoemaniera_database.db'));
