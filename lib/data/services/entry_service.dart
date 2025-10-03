import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class EntryService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'trackerDb.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      onUpgrade: (db, oldVersion, newVersion) async {
        log('Upgrading database from version $oldVersion to $newVersion');
      },
    );
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_entries (
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
  }

  Future<List<dynamic>> getAllEntries() async {
    final db = await database;
    final data = await db.query(
      'daily_entries',
      orderBy: 'date DESC, startTime DESC ',
    );
    return data;
  }

  Future<int> insertEntry(dynamic data) async {
    final db = await database;
    return await db.insert('daily_entries', data);
  }

  Future<int> updateEntry(String id, dynamic data) async {
    final db = await database;
    return await db.update(
      'daily_entries',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await database;
    return await db.delete('daily_entries', where: 'id = ?', whereArgs: [id]);
  }
}
