import 'package:equatable/equatable.dart';
import 'package:stage/models/movie_list_model.dart';

abstract class FavoriteMovieState extends Equatable {
  const FavoriteMovieState();

  @override
  List<Object?> get props => [];
}

class FavoriteMovieInitialState extends FavoriteMovieState {}

class FavoriteMovieLoadingState extends FavoriteMovieState {}

class FavoriteMovieErrorState extends FavoriteMovieState {
  final String message;

  const FavoriteMovieErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class FavoriteMovieAddedState extends FavoriteMovieState {
  final Movie movie;

  const FavoriteMovieAddedState({required this.movie});

  @override
  List<Object?> get props => [movie];
}

class FavoriteMovieRemovedState extends FavoriteMovieState {
  final int movieId;

  const FavoriteMovieRemovedState({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}

class FavoriteMovieCheckedState extends FavoriteMovieState {
  final int movieId;
  final bool isFavorite;

  const FavoriteMovieCheckedState({
    required this.movieId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [movieId, isFavorite];
}

class FavoriteMovieLoadedState extends FavoriteMovieState {
  final List<Movie> favoriteMovies;

  const FavoriteMovieLoadedState({required this.favoriteMovies});

  @override
  List<Object?> get props => [favoriteMovies];
}
