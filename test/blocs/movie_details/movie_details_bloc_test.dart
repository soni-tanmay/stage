import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stage/blocs/movie_details/movie_details_bloc.dart';
import 'package:stage/blocs/movie_details/movie_details_event.dart';
import 'package:stage/blocs/movie_details/movie_details_state.dart';
import 'package:stage/repositories/movie_repository.dart';
import 'package:stage/models/movie_details_model.dart';

import 'movie_details_bloc_test.mocks.dart';

@GenerateMocks([MovieRepository])
void main() {
  late MovieDetailsBloc movieDetailsBloc;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    movieDetailsBloc = MovieDetailsBloc(movieRepository: mockMovieRepository);
  });

  tearDown(() {
    movieDetailsBloc.close();
  });

  test('initial state is MovieDetailsInitialState', () {
    expect(movieDetailsBloc.state, MovieDetailsInitialState());
  });

  final MovieDetails movieDetails = MovieDetails(
    id: 1,
    title: 'Test Movie',
    overview: 'Test Overview',
  );

  blocTest<MovieDetailsBloc, MovieDetailsState>(
    'emits [MovieDetailsLoadingState, MovieDetailsLoadedState] when data is fetched successfully',
    build: () {
      when(
        mockMovieRepository.fetchMovieDetails(any),
      ).thenAnswer((_) async => movieDetails);
      return movieDetailsBloc;
    },
    act: (bloc) => bloc.add(LoadMovieDetailsEvent(movieId: 1)),
    expect:
        () => [
          MovieDetailsLoadingState(),
          MovieDetailsLoadedState(movieDetails: movieDetails),
        ],
    verify: (_) {
      verify(mockMovieRepository.fetchMovieDetails(1)).called(1);
    },
  );

  blocTest<MovieDetailsBloc, MovieDetailsState>(
    'emits [MovieDetailsLoadingState, MovieDetailsErrorState] when an error occurs',
    build: () {
      when(
        mockMovieRepository.fetchMovieDetails(any),
      ).thenThrow(Exception('Error fetching movie details'));
      return movieDetailsBloc;
    },
    act: (bloc) => bloc.add(LoadMovieDetailsEvent(movieId: 1)),
    expect:
        () => [
          MovieDetailsLoadingState(),
          MovieDetailsErrorState(
            message: 'Exception: Error fetching movie details',
          ),
        ],
    verify: (_) {
      verify(mockMovieRepository.fetchMovieDetails(1)).called(1);
    },
  );
}
