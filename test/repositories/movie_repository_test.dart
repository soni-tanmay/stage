import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stage/repositories/movie_repository.dart';
import 'package:stage/models/movie_list_model.dart';

import 'movie_repository_test.mocks.dart';

@GenerateMocks([MovieRepository])
void main() {
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
  });

  group('MovieRepository', () {
    test('fetchMovies returns MovieList when successful', () async {
      final movieList = MovieList(
        page: 1,
        results: [],
        totalPages: 1,
        totalResults: 10,
      );

      when(
        mockMovieRepository.fetchMovies(any),
      ).thenAnswer((_) async => movieList);

      final result = await mockMovieRepository.fetchMovies(1);

      expect(result, movieList);
      verify(mockMovieRepository.fetchMovies(1)).called(1);
    });

    test('fetchMovies throws Exception when an error occurs', () async {
      when(
        mockMovieRepository.fetchMovies(any),
      ).thenThrow(Exception('Error fetching movies'));

      expect(() => mockMovieRepository.fetchMovies(1), throwsException);
      verify(mockMovieRepository.fetchMovies(1)).called(1);
    });
  });
}
