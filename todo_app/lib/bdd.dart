import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'modele_tache.dart';

class BDTache {
  static final BDTache _instance = BDTache._internal();
  factory BDTache() => _instance;
  static Database? _database;

  BDTache._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        completed INTEGER,
        status TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    Database db = await database;
    return await db.query('tasks');
  }

  Future<List<Map<String, dynamic>>> getTasksByStatuses(
      List<String> statuses) async {
    Database db = await database;
    String whereClause =
        'status IN (${List.filled(statuses.length, '?').join(', ')})';
    return await db.query('tasks', where: whereClause, whereArgs: statuses);
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.insert('tasks', task);
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    Database db = await database;
    return await db
        .update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
