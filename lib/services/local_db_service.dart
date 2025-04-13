import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stage/models/movie_list_model.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT,
            overview TEXT,
            poster_path TEXT,
            vote_average REAL,
            release_date TEXT
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(Movie movie) async {
    final dbClient = await db;
    await dbClient.insert(
      'favorites',
      movie.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await getFavorites();
  }

  Future<void> removeFavorite(int movieId) async {
    final dbClient = await db;
    await dbClient.delete('favorites', where: 'id = ?', whereArgs: [movieId]);
    await getFavorites();
  }

  Future<List<Movie>> getFavorites() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorites');
    return maps.map((map) => Movie.fromDb(map)).toList();
  }

  Future<bool> isFavorite(int movieId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [movieId],
    );
    return result.isNotEmpty;
  }
}
