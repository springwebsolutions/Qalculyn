// Qalculyn - History Repository
// Manages persistence of calculation history

import '../models.dart';
import '../storage/database_helper.dart';

class HistoryRepository {
  static const int _maxEntries = 500;

  Future<List<HistoryEntry>> getAll({String? search, String? calculatorType}) async {
    final db = await DatabaseHelper.database;

    String where = '1=1';
    final args = <dynamic>[];

    if (search != null && search.isNotEmpty) {
      where += ' AND (expression LIKE ? OR result LIKE ?)';
      args.add('%$search%');
      args.add('%$search%');
    }

    if (calculatorType != null) {
      where += ' AND calculator_type = ?';
      args.add(calculatorType);
    }

    final maps = await db.query(
      'calculation_history',
      where: where,
      whereArgs: args,
      orderBy: 'timestamp DESC',
      limit: _maxEntries,
    );

    return maps.map((m) => HistoryEntry.fromMap(m)).toList();
  }

  Future<HistoryEntry> insert(HistoryEntry entry) async {
    final db = await DatabaseHelper.database;
    final id = await db.insert('calculation_history', entry.toMap());

    // Enforce max entries
    await _trimOldEntries(db);

    return entry.copyWith(id: id);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('calculation_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await DatabaseHelper.database;
    await db.delete('calculation_history');
  }

  Future<int> count() async {
    final db = await DatabaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM calculation_history');
    return result.first['count'] as int;
  }

  Future<void> _trimOldEntries(dynamic db) async {
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM calculation_history');
    final total = count.first['count'] as int;

    if (total > _maxEntries) {
      await db.rawDelete('''
        DELETE FROM calculation_history 
        WHERE id NOT IN (
          SELECT id FROM calculation_history 
          ORDER BY timestamp DESC 
          LIMIT $_maxEntries
        )
      ''');
    }
  }
}
