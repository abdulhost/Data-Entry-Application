// lib/features/dashboard/entry_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'entry_model.dart';

class EntryRepository {
  static final EntryRepository _instance = EntryRepository._internal();
  factory EntryRepository() => _instance;
  EntryRepository._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'entries.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries(
            id TEXT PRIMARY KEY,
            name TEXT,
            phone TEXT,
            address TEXT,
            variant TEXT,
            color TEXT,
            amount REAL,
            date TEXT,
            time TEXT
          )
        ''');
      },
    );
  }

  Future<void> insert(Entry entry) async {
    final database = await db;
    await database.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Entry entry) async {
    final database = await db;
    await database.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Entry>> getEntries({int limit = 10, int offset = 0, String query = ''}) async {
    final database = await db;
    final result = await database.query(
      'entries',
      where: query.isNotEmpty ? 'name LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%'] : null,
      limit: limit,
      offset: offset,
      orderBy: 'date DESC, time DESC',
    );
    return result.map((e) => Entry.fromMap(e)).toList();
  }
}