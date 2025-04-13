import 'package:equatable/equatable.dart';
import 'package:stage/models/movie_details_model.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsInitialState extends MovieDetailsState {}

class MovieDetailsLoadingState extends MovieDetailsState {}

class MovieDetailsErrorState extends MovieDetailsState {
  final String message;

  const MovieDetailsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class MovieDetailsLoadedState extends MovieDetailsState {
  final MovieDetails movieDetails;

  const MovieDetailsLoadedState({required this.movieDetails});

  @override
  List<Object?> get props => [movieDetails];
}
