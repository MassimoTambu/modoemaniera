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

// void connect() async {
//   database = openDatabase(
//     // Set the path to the database. Note: Using the `join` function from the
//     // `path` package is best practice to ensure the path is correctly
//     // constructed for each platform.
//     join(await getDatabasesPath(), 'modoemaniera_database.db'),
//     // When the database is first created, create a table to store dogs.
//     onCreate: (db, version) async {
//       print('create');

//       // Run the CREATE TABLE statement on the database.
//       db
//           .execute(
//         "CREATE TABLE counters(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)",
//       )
//           .catchError((e) {
//         print(e);
//       }).then((_) async {
//         basicCounters.forEach((c) {
//           db.insert('counters', {'name': c.cName});
//         });
//         counters = await getCounters();
//       });
//       return;
//     },
//     onOpen: (db) async {
//       print('open');
//       counters = await getCounters();
//       print(counters);
//     },
//     // Set the version. This executes the onCreate function and provides a
//     // path to perform database upgrades and downgrades.
//     version: 1,
//   );
// }

class CounterTable {
  static const tName = 'counters';
  static const id = 'id';
  static const name = 'name';
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
    final countersSql = '''CREATE TABLE ${CounterTable.tName}
    (
      ${CounterTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CounterTable.name} TEXT
    )''';

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
    openDatabase(path, version: 1, onCreate: _onCreate).then((_db) {
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

    return List.generate(data.length, (i) {
      return Counter(
        data[i]['id'],
        data[i]['name'],
        [DateTime.now()],
      );
    });
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
  }

  static Future<void> deleteCounter(Counter counter) async {
    final sql = '''DELETE FROM ${CounterTable.tName}
    WHERE id = ${counter.id}
    ''';
    final result = await db.rawDelete(sql);
    DatabaseCreator.databaseLog('Delete Counter', sql, null, result);
  }

  static Future<void> updateCounter(Counter counter) async {
    final sql = '''UPDATE ${CounterTable.tName}
    SET ${CounterTable.name} = "${counter.name}"
    WHERE id = ${counter.id}
    ''';
    final result = await db.rawUpdate(sql);
    DatabaseCreator.databaseLog('Delete Counter', sql, null, result);
  }
}

Future<void> deleteDatabase() async => databaseFactory
    .deleteDatabase(join(await getDatabasesPath(), 'modoemaniera_database.db'));

// // Define a function that inserts dogs into the database
// Future<void> insertCounter(Counter counter) async {
//   // Get a reference to the database.
//   final Database db = await database;
//   print(db);
//   // Insert the Dog into the correct table. You might also specify the
//   // `conflictAlgorithm` to use in case the same dog is inserted twice.
//   //
//   // In this case, replace any previous data.
//   await db.insert(
//     'counters',
//     counter.toMap(),
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }

// Future<List<Counter>> getCounters() async {
//   // Get a reference to the database.
//   final Database db = await database;

//   // Query the table for all The Dogs.
//   final List<Map<String, dynamic>> maps = await db.query('counters');

//   // Convert the List<Map<String, dynamic> into a List<Dog>.
//   return List.generate(maps.length, (i) {
//     return Counter(
//       maps[i]['id'],
//       maps[i]['name'],
//       [DateTime.now()],
//     );
//   });
// }
