import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stage/models/movie_details_model.dart';
import 'package:stage/models/movie_list_model.dart';

class ApiService {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  Future<MovieList> getMovies(int page) async {
    final url = Uri.parse(
      '$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=$page',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieList movieList = MovieList.fromJson(data);
      return movieList;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final url = Uri.parse(
      '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final MovieDetails movieDetails = MovieDetails.fromJson(data);
      return movieDetails;
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}
