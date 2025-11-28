import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sewabustravel/models/local_feedback_model.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sewabustravel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE feedback ( 
  id $idType, 
  userId TEXT NOT NULL,
  rating $integerType,
  comment $textType,
  createdAt $textType
  )
''');
    print('Tabel Feedback Lokal Berhasil Dibuat.');
  }

  Future<int> createFeedback(LocalFeedbackModel feedback) async {
    final db = await instance.database;

    final id = await db.insert(
      'feedback',
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Feedback ID $id Berhasil Disimpan Lokal.');
    return id;
  }

  Future<List<LocalFeedbackModel>> readAllFeedback() async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';

    final result = await db.query('feedback', orderBy: orderBy);

    return result.map((json) => LocalFeedbackModel.fromMap(json)).toList();
  }

  Future<List<LocalFeedbackModel>> readAllFeedbackByUserId(
    String userId,
  ) async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';

    final result = await db.query(
      'feedback',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: orderBy,
    );

    return result.map((json) => LocalFeedbackModel.fromMap(json)).toList();
  }

  Future<int> deleteFeedback(int id) async {
    final db = await instance.database;
    return await db.delete('feedback', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    final isClosed = db.isOpen;
    if (isClosed) {
      db.close();
      _database = null;
    }
  }
}
