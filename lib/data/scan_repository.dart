import 'app_database.dart';
import 'scan_record.dart';

class ScanRepository {
  final AppDatabase _appDb;

  ScanRepository(this._appDb);

  Future<void> save(ScanRecord record) async {
    final db = await _appDb.database;
    await db.insert(AppDatabase.table, record.toMap());
  }

  /// Newest first.
  Future<List<ScanRecord>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.query(AppDatabase.table, orderBy: 'created_at DESC');
    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<void> deleteAll() async {
    final db = await _appDb.database;
    await db.delete(AppDatabase.table);
  }
}
