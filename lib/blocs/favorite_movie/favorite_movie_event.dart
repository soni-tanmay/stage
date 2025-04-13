import 'package:stage/models/movie_list_model.dart';

abstract class FavoriteMovieEvent {}

class AddFavoriteMovieEvent extends FavoriteMovieEvent {
  final Movie movie;

  AddFavoriteMovieEvent({required this.movie});
}

class RemoveFavoriteMovieEvent extends FavoriteMovieEvent {
  final int movieId;

  RemoveFavoriteMovieEvent({required this.movieId});
}

class CheckFavoriteMovieEvent extends FavoriteMovieEvent {
  final int movieId;

  CheckFavoriteMovieEvent({required this.movieId});
}

class LoadFavoriteMoviesEvent extends FavoriteMovieEvent {}
