import 'package:stage/models/movie_details_model.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/services/api_service.dart';
import 'package:stage/services/local_db_service.dart';

class MovieRepository {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDbService = LocalDbService();

  Future<MovieList> fetchMovies(int page) async {
    try {
      final movieList = await _apiService.getMovies(page);
      return movieList;
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<MovieDetails> fetchMovieDetails(int movieId) async {
    try {
      final movieDetails = await _apiService.getMovieDetails(movieId);
      return movieDetails;
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  Future<List<Movie>> getFavoriteMovies() async {
    try {
      return await _localDbService.getFavorites();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<void> addMovieToFavorites(Movie movie) async {
    try {
      await _localDbService.addFavorite(movie);
    } catch (e) {
      throw Exception('Failed to add movie to favorites: $e');
    }
  }

  Future<void> removeMovieFromFavorites(int movieId) async {
    try {
      await _localDbService.removeFavorite(movieId);
    } catch (e) {
      throw Exception('Failed to remove movie from favorites: $e');
    }
  }

  Future<bool> isMovieFavorite(int movieId) async {
    try {
      return await _localDbService.isFavorite(movieId);
    } catch (e) {
      throw Exception('Failed to check if movie is favorite: $e');
    }
  }
}
