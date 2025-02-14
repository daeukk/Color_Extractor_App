import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'color_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE colors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            extractedData TEXT
          )
        ''');
      },
    );
  }

  Future<int> saveExtractedColors(
      String imagePath, Map<String, dynamic> extractedColors) async {
    final db = await database;
    return await db.insert(
      'colors',
      {
        'imagePath': imagePath,
        'extractedData': extractedColors.toString(), // Store as string
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchExtractedColors() async {
    final db = await database;
    return await db.query('colors');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('colors');
  }
}
