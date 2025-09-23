import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/daily_entry.dart';

class EntryRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'tracker.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            uberEarnings REAL NOT NULL,
            tips REAL NOT NULL,
            fuelCost REAL NOT NULL,
            foodCost REAL NOT NULL,
            cleaningCost REAL NOT NULL,
            otherCosts REAL NOT NULL,
            kmDriven REAL NOT NULL,
            hoursWorked REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        uberEarnings REAL NOT NULL,
        tips REAL NOT NULL,
        fuelCost REAL NOT NULL,
        foodCost REAL NOT NULL,
        cleaningCost REAL NOT NULL,
        otherCosts REAL NOT NULL,
        kmDriven REAL NOT NULL,
        hoursWorked REAL NOT NULL
      )
    ''');
  }

  Future<int> insertEntry(DailyEntry entry) async {
    final db = await database;
    return await db.insert('daily_entries', entry.toMap());
  }

  Future<List<DailyEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('daily_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => DailyEntry.fromMap(maps[i]));
  }

  Future<List<DailyEntry>> getEntriesByMonth(int year, int month) async {
    final db = await database;
    final maps = await db.query(
      'daily_entries',
      where: 'strftime("%Y-%m", date) = ?',
      whereArgs: [
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}',
      ],
    );
    return List.generate(maps.length, (i) => DailyEntry.fromMap(maps[i]));
  }

  Future<int> updateEntry(DailyEntry entry) async {
    final db = await database;
    return await db.update(
      'daily_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('daily_entries', where: 'id = ?', whereArgs: [id]);
  }
}
