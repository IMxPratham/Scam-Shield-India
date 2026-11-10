import 'package:flutter_test/flutter_test.dart';
import 'package:scam_shield/core/detector.dart';
import 'package:scam_shield/data/app_database.dart';
import 'package:scam_shield/data/scan_record.dart';
import 'package:scam_shield/data/scan_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

ScanRecord makeRecord(String text, DateTime when) => ScanRecord.fromResult(
  text,
  DetectionResult(10, [Finding('test reason', 10)]),
  now: when,
);

void main() {
  late AppDatabase appDb;
  late ScanRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // A fresh, empty in-memory database before EVERY test.
  setUp(() {
    appDb = AppDatabase(path: inMemoryDatabasePath);
    repo = ScanRepository(appDb);
  });

  tearDown(() async {
    final db = await appDb.database;
    await db.close();
  });

  test('new database has no records', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('save then getAll returns the record', () async {
    await repo.save(makeRecord('hello', DateTime(2026, 1, 1)));
    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.first.inputPreview, 'hello');
    expect(all.first.findings.first.reason, 'test reason');
  });

  test('getAll returns newest first', () async {
    await repo.save(makeRecord('old', DateTime(2026, 1, 1)));
    await repo.save(makeRecord('new', DateTime(2026, 3, 1)));
    await repo.save(makeRecord('middle', DateTime(2026, 2, 1)));
    final all = await repo.getAll();
    expect(all.map((r) => r.inputPreview).toList(), ['new', 'middle', 'old']);
  });

  test('deleteAll empties the table', () async {
    await repo.save(makeRecord('a', DateTime(2026, 1, 1)));
    await repo.save(makeRecord('b', DateTime(2026, 1, 2)));
    await repo.deleteAll();
    expect(await repo.getAll(), isEmpty);
  });
}
