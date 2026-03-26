import 'package:first_app/features/dashboard/entry_model.dart';
import 'package:first_app/core/db/database_helper.dart';
import 'package:first_app/core/services/google_sheets_service.dart';
import 'package:sqflite/sqflite.dart';

class EntryRepository {
  static final EntryRepository _instance = EntryRepository._internal();
  factory EntryRepository() => _instance;
  EntryRepository._internal();

  final GoogleSheetsService _sheetService = GoogleSheetsService();

  /// INSERT
  Future<void> insert(Entry entry) async {
    final db = await DatabaseHelper.instance.database;

    final data = entry.toMap();
    data['isSynced'] = 0;

    await db.insert(
      'entries',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// UPDATE
  Future<void> update(Entry entry) async {
    final db = await DatabaseHelper.instance.database;

    final data = entry.toMap();
    data['isSynced'] = 0;

    await db.update(
      'entries',
      data,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// DELETE
  Future<void> delete(Entry entry) async {
    final db = await DatabaseHelper.instance.database;

    try {
      await _sheetService.deleteById(entry.id); // ✅ correct method
    } catch (e) {
      print("❌ Sheet delete failed: $e");
    }

    await db.delete('entries', where: 'id = ?', whereArgs: [entry.id]);
  }

  /// GET
  Future<List<Entry>> getEntries({
    int limit = 50,
    int offset = 0,
    String query = '',
  }) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'entries',
      where: query.isNotEmpty ? 'name LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%'] : null,
      limit: limit,
      offset: offset,
      orderBy: 'date DESC, time DESC',
    );

    return result.map((e) => Entry.fromMap(e)).toList();
  }

  /// ✅ CLEAN SYNC (NO OLD METHODS)
  Future<void> syncToGoogleSheets() async {
    final db = await DatabaseHelper.instance.database;

    final result =
    await db.query('entries', where: 'isSynced = ?', whereArgs: [0]);

    if (result.isEmpty) return;

    final entries = result.map((e) => Entry.fromMap(e)).toList();

    print('🚀 Syncing ${entries.length} entries...');

    try {
      for (var e in entries) {
        final exists = await _sheetService.checkIfExists(e.id);

        if (exists) {
          await _sheetService.updateById(e);
        } else {
          await _sheetService.appendEntry(e);
        }

        await db.update(
          'entries',
          {'isSynced': 1},
          where: 'id = ?',
          whereArgs: [e.id],
        );
      }

      print('✅ Sync complete');
    } catch (e, s) {
      print('❌ Sync failed: $e\n$s');
    }
  }
}