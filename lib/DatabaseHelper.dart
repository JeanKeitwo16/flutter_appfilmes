import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_appfilmes/filmecurtido.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'filmes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE MovieLiked(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imdbID TEXT UNIQUE
          )
        ''');
      },
    );
  }

  Future<void> favoritarFilme(String imdbID) async {
    final db = await database;
    await db.insert(
      'MovieLiked',
      {'imdbID': imdbID},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Não adicionar se já existir
    );
  }

  Future<List<FilmeCurtido>> getFilmes() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('MovieLiked');
  return List.generate(maps.length, (i) {
    return FilmeCurtido.fromMap(maps[i]);
  });
}

  Future<void> removerFilme(String imdbID) async {
    final db = await database;
    await db.delete(
      'MovieLiked',
      where: 'imdbID = ?',
      whereArgs: [imdbID],
    );
  }
  Future<bool> verificarFavorito(String imdbID) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'MovieLiked',
      where: 'imdbID = ?',
      whereArgs: [imdbID],
    );
    return result.isNotEmpty; // Retorna true se houver resultados, ou false caso contrário
  }
}
