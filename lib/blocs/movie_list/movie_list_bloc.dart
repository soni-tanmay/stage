import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/repositories/movie_repository.dart';
import 'movie_list_event.dart';
import 'movie_list_state.dart';

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final MovieRepository movieRepository;
  MovieListBloc({required this.movieRepository})
    : super(MovieListInitialState()) {
    on<LoadMoviesListEvent>(
      (event, emit) => _onLoadMoviesListEvent(event, emit),
    );
  }

  void _onLoadMoviesListEvent(
    LoadMoviesListEvent event,
    Emitter<MovieListState> emit,
  ) async {
    emit(MovieListLoadingState());
    try {
      final result = await movieRepository.fetchMovies(event.page);

      List<Movie> movieList = result.results ?? [];

      bool isLoadingMore =
          (result.page != null) &&
          (result.totalPages != null) &&
          (result.page! < result.totalPages!);

      emit(
        MovieListLoadedState(
          movieList: movieList,
          isLoadingMore: isLoadingMore,
        ),
      );
    } catch (e) {
      emit(MovieListErrorState(message: e.toString()));
    }
  }
}
