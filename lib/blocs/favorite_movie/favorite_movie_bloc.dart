import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_event.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/services/local_db_service.dart';

class FavoriteMovieBloc extends Bloc<FavoriteMovieEvent, FavoriteMovieState> {
  final LocalDbService localDbService = LocalDbService();

  FavoriteMovieBloc() : super(FavoriteMovieInitialState()) {
    on<AddFavoriteMovieEvent>(
      (event, emit) => _onAddFavoriteMovieEvent(event, emit),
    );
    on<RemoveFavoriteMovieEvent>(
      (event, emit) => _onRemoveFavoriteMovieEvent(event, emit),
    );
    on<CheckFavoriteMovieEvent>(
      (event, emit) => _onCheckFavoriteMovieEvent(event, emit),
    );
    on<LoadFavoriteMoviesEvent>(
      (event, emit) => _onLoadFavoriteMoviesEvent(event, emit),
    );
  }

  void _onAddFavoriteMovieEvent(
    AddFavoriteMovieEvent event,
    Emitter<FavoriteMovieState> emit,
  ) async {
    try {
      emit(FavoriteMovieLoadingState());
      await localDbService.addFavorite(event.movie);
      add(LoadFavoriteMoviesEvent());
      emit(FavoriteMovieAddedState(movie: event.movie));
    } catch (e) {
      emit(
        FavoriteMovieErrorState(
          message: 'Failed to add favorite: ${e.toString()}',
        ),
      );
    }
  }

  void _onRemoveFavoriteMovieEvent(
    RemoveFavoriteMovieEvent event,
    Emitter<FavoriteMovieState> emit,
  ) async {
    try {
      emit(FavoriteMovieLoadingState());
      await localDbService.removeFavorite(event.movieId);
      add(LoadFavoriteMoviesEvent());
      emit(FavoriteMovieRemovedState(movieId: event.movieId));
    } catch (e) {
      emit(
        FavoriteMovieErrorState(
          message: 'Failed to remove favorite: ${e.toString()}',
        ),
      );
    }
  }

  void _onCheckFavoriteMovieEvent(
    CheckFavoriteMovieEvent event,
    Emitter<FavoriteMovieState> emit,
  ) async {
    try {
      final isFavorite = await localDbService.isFavorite(event.movieId);
      emit(FavoriteMovieLoadingState());

      emit(
        FavoriteMovieCheckedState(
          movieId: event.movieId,
          isFavorite: isFavorite,
        ),
      );
    } catch (e) {
      emit(
        FavoriteMovieErrorState(
          message: 'Failed to check favorite: ${e.toString()}',
        ),
      );
    }
  }

  void _onLoadFavoriteMoviesEvent(
    LoadFavoriteMoviesEvent event,
    Emitter<FavoriteMovieState> emit,
  ) async {
    try {
      emit(FavoriteMovieLoadingState());
      final favorites = await localDbService.getFavorites();
      emit(FavoriteMovieLoadedState(favoriteMovies: favorites));
    } catch (e) {
      emit(
        FavoriteMovieErrorState(
          message: 'Failed to load favorites: ${e.toString()}',
        ),
      );
    }
  }
}
