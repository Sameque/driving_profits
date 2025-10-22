import 'dart:developer';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef OnCreateCallback = Future<void> Function(Database db, int version);
typedef OnUpgradeCallback =
    Future<void> Function(Database db, int oldVersion, int newVersion);

class DatabaseService {
  static const _dbName = 'trackerDb.db';
  static const _dbVersion = 10;

  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) => _createDb,
      onUpgrade: _upgrade,
    );
  }

  // Generic CRUD helpers
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? orderBy,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
  }

  void _upgrade(db, int oldVersion, int newVersion) async {
    log(
      'EntryService: Upgrading database from version $oldVersion to $newVersion',
    );
  }

  void _createDb(db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        uberEarnings REAL NOT NULL,
        tips REAL NOT NULL,
        fuelCost REAL NOT NULL,
        foodCost REAL NOT NULL,
        cleaningCost REAL NOT NULL,
        otherCosts REAL NOT NULL,
        kmEnd INT NOT NULL,
        kmStart INT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        status TEXT NULL
      )
    ''');

    await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type INTEGER,
            amount REAL
          )
        ''');
  }
}
