import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stage/blocs/movie_list/movie_list_bloc.dart';
import 'package:stage/blocs/movie_list/movie_list_event.dart';
import 'package:stage/blocs/movie_list/movie_list_state.dart';
import 'package:stage/repositories/movie_repository.dart';
import 'package:stage/models/movie_list_model.dart';

import 'movie_list_bloc_test.mocks.dart';

@GenerateMocks([MovieRepository])
void main() {
  late MovieListBloc movieListBloc;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    movieListBloc = MovieListBloc(movieRepository: mockMovieRepository);
  });

  tearDown(() {
    movieListBloc.close();
  });

  test('initial state is MovieListInitialState', () {
    expect(movieListBloc.state, MovieListInitialState());
  });

  final MovieList movieList1 = MovieList(
    page: 1,
    results: [
      Movie(id: 1, title: 'Movie 1', posterPath: '/path1.jpg'),
      Movie(id: 2, title: 'Movie 2', posterPath: '/path2.jpg'),
    ],
    totalPages: 1,
    totalResults: 2,
  );

  blocTest<MovieListBloc, MovieListState>(
    'emits [MovieListLoadingState, MovieListLoadedState] when data is fetched successfully',
    build: () {
      when(
        mockMovieRepository.fetchMovies(any),
      ).thenAnswer((_) async => movieList1);
      return movieListBloc;
    },
    act: (bloc) => bloc.add(LoadMoviesListEvent(page: 1)),
    expect:
        () => [
          MovieListLoadingState(),
          MovieListLoadedState(
            movieList: movieList1.results ?? [],
            isLoadingMore: false,
          ),
        ],
    verify: (_) {
      verify(mockMovieRepository.fetchMovies(1)).called(1);
    },
  );

  blocTest<MovieListBloc, MovieListState>(
    'emits [MovieListLoadingState, MovieListErrorState] when an error occurs',
    build: () {
      when(
        mockMovieRepository.fetchMovies(any),
      ).thenThrow(Exception('Error fetching movies'));
      return movieListBloc;
    },
    act: (bloc) => bloc.add(LoadMoviesListEvent(page: 1)),
    expect:
        () => [
          MovieListLoadingState(),
          MovieListErrorState(message: 'Exception: Error fetching movies'),
        ],
    verify: (_) {
      verify(mockMovieRepository.fetchMovies(1)).called(1);
    },
  );

  final MovieList movieList2 = MovieList(
    page: 2,
    results: [Movie(id: 3, title: 'Movie 3', posterPath: '/path3.jpg')],
    totalPages: 2,
    totalResults: 3,
  );

  blocTest<MovieListBloc, MovieListState>(
    'emits [MovieListLoadingState, MovieListLoadedState] when loading more movies',
    build: () {
      when(
        mockMovieRepository.fetchMovies(any),
      ).thenAnswer((_) async => movieList2);
      return movieListBloc;
    },
    act: (bloc) {
      bloc.add(LoadMoviesListEvent(page: 2));
    },
    expect:
        () => [
          MovieListLoadingState(),
          MovieListLoadedState(
            movieList: movieList2.results ?? [],
            isLoadingMore: false,
          ),
        ],
    verify: (_) {
      verify(mockMovieRepository.fetchMovies(2)).called(1);
    },
  );
}
