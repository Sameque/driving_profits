// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:driving_profits/models/daily_entry.dart';

// class DatabaseHelper {
//   static const _databaseName = "UberFinance.db";
//   static const _databaseVersion = 2;

//   static const table = 'entries';

//   static const columnId = 'id';
//   static const columnDate = 'date';
//   // ... adicione outras colunas aqui

//   // torna esta uma classe singleton
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

//   static Database? _database;
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   _initDatabase() async {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = join(documentsDirectory.path, _databaseName);
//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _onCreate,
//     );
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//           CREATE TABLE entries (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             date TEXT NOT NULL,
//             uberEarnings REAL NOT NULL,
//             tips REAL NOT NULL,
//             fuelCost REAL NOT NULL,
//             foodCost REAL NOT NULL,
//             cleaningCost REAL NOT NULL,
//             otherCosts REAL NOT NULL,
//             kmDriven REAL NOT NULL,
//             hoursWorked REAL NOT NULL,
//             rides INTEGER,
//             grossEarnings REAL,
//             uberFees REAL,
//             otherExpenses REAL,
//             maintenanceCost REAL
//           )
//           ''');
//   }

//   // Métodos CRUD (Create, Read, Update, Delete)
//   Future<int> insert(Entry entry) async {
//     Database db = await instance.database;
//     return await db.insert(table, entry.toMap());
//   }

//   Future<List<Entry>> getAllEntries() async {
//     Database db = await instance.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       table,
//       orderBy: "date DESC",
//     );

//     return List.generate(maps.length, (i) {
//       return Entry.fromMap(maps[i]);
//     });
//   }

//   // Você pode adicionar métodos de update e delete aqui depois
// }
