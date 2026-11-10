import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String table = 'scans';
  static const String _fileName = 'scamshield.db';
  static const int _version = 1;

  /// null = the real file on the phone. Tests pass inMemoryDatabasePath.
  final String? _path;

  AppDatabase({this._path});

  Future<Database>? _opening;

  /// Opens the database once. Later calls reuse the same Future.
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final path = _path ?? join(await getDatabasesPath(), _fileName);
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            input_preview TEXT NOT NULL,
            score INTEGER NOT NULL,
            verdict TEXT NOT NULL,
            reasons_json TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
