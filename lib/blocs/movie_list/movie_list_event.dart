abstract class MovieListEvent {}

class LoadMoviesListEvent extends MovieListEvent {
  final int page;

  LoadMoviesListEvent({required this.page});
}
