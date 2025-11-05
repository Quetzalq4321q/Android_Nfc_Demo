import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'nfc_proyecto.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE persona(
        id TEXT PRIMARY KEY,
        nombre TEXT,
        grupo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag_id TEXT,
        fecha TEXT,
        resultado TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tag_id TEXT,
          fecha TEXT,
          resultado TEXT
        )
      ''');
    }
  }

  Future<void> close() async {
    final database = await db;
    await database.close();
    _db = null;
  }
}
