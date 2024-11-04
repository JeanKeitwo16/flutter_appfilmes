import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_appfilmes/movieliked.dart';

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

  Future<void> addMovieToFavorites(String imdbID) async {
    final db = await database;
    await db.insert(
      'MovieLiked',
      {'imdbID': imdbID},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Não adicionar se já existir
    );
  }

  Future<List<MovieLiked>> getFavoriteMovies() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('MovieLiked');

  // Converte a lista de maps em uma lista de MovieLiked
  return List.generate(maps.length, (i) {
    return MovieLiked.fromMap(maps[i]);
  });
}

  Future<void> removeMovieFromFavorites(String imdbID) async {
    final db = await database;
    await db.delete(
      'MovieLiked',
      where: 'imdbID = ?',
      whereArgs: [imdbID],
    );
  }
}
