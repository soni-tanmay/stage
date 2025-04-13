import 'package:equatable/equatable.dart';
import 'package:stage/models/movie_list_model.dart';

abstract class MovieListState extends Equatable {
  const MovieListState();

  @override
  List<Object?> get props => [];
}

class MovieListInitialState extends MovieListState {}

class MovieListLoadingState extends MovieListState {}

class MovieListErrorState extends MovieListState {
  final String message;

  const MovieListErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MovieListLoadedState extends MovieListState {
  final List<Movie> movieList;
  final bool isLoadingMore;

  const MovieListLoadedState({
    required this.movieList,
    required this.isLoadingMore,
  });

  @override
  List<Object?> get props => [movieList, isLoadingMore];
}
