import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/movie_details/movie_details_event.dart';
import 'package:stage/blocs/movie_details/movie_details_state.dart';
import 'package:stage/repositories/movie_repository.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieRepository movieRepository;

  MovieDetailsBloc({required this.movieRepository})
    : super(MovieDetailsInitialState()) {
    on<LoadMovieDetailsEvent>(
      (event, emit) => _onLoadMovieDetailsEvent(event, emit),
    );
  }

  void _onLoadMovieDetailsEvent(
    LoadMovieDetailsEvent event,
    Emitter<MovieDetailsState> emit,
  ) async {
    emit(MovieDetailsLoadingState());

    try {
      final movieDetails = await movieRepository.fetchMovieDetails(
        event.movieId,
      );
      emit(MovieDetailsLoadedState(movieDetails: movieDetails));
    } catch (e) {
      emit(MovieDetailsErrorState(message: e.toString()));
    }
  }
}
