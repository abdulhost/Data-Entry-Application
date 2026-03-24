// lib/core/db/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Delete old DB for dev testing only (optional)
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 2, // ⚡ Increment version if schema changed
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE entries (
      id TEXT PRIMARY KEY,
      name TEXT,
      phone TEXT,
      address TEXT,
      variant TEXT,
      color TEXT,
      amount TEXT,
      date TEXT,
      time TEXT
    )
    ''');
  }

  // Migration handler
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // If table existed before, drop and recreate (dev only)
      await db.execute('DROP TABLE IF EXISTS entries');
      await _createDB(db, newVersion);
    }
  }
}