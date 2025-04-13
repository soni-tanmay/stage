import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/blocs/movie_details/movie_details_bloc.dart';
import 'package:stage/blocs/movie_details/movie_details_state.dart';
import 'package:stage/models/movie_details_model.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/screens/movie_detail_screen.dart';
import 'package:stage/services/connectivity_service.dart';

class MockMovieDetailsBloc extends Mock implements MovieDetailsBloc {}

class MockFavoriteMovieBloc extends Mock implements FavoriteMovieBloc {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMovieDetailsBloc mockMovieDetailsBloc;
  late MockFavoriteMovieBloc mockFavoriteMovieBloc;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockMovieDetailsBloc = MockMovieDetailsBloc();
    mockFavoriteMovieBloc = MockFavoriteMovieBloc();
    mockConnectivityService = MockConnectivityService();

    when(
      () => mockConnectivityService.isConnected(),
    ).thenAnswer((_) async => true);
    when(
      () => mockConnectivityService.connectionStatus,
    ).thenAnswer((_) => const Stream<bool>.empty());
    when(
      () => mockMovieDetailsBloc.stream,
    ).thenAnswer((_) => const Stream<MovieDetailsState>.empty());
    when(
      () => mockFavoriteMovieBloc.stream,
    ).thenAnswer((_) => const Stream<FavoriteMovieState>.empty());
  });

  Widget createWidgetUnderTest(Movie movie) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MovieDetailsBloc>.value(value: mockMovieDetailsBloc),
          BlocProvider<FavoriteMovieBloc>.value(value: mockFavoriteMovieBloc),
        ],
        child: MovieDetailScreen(
          movie: movie,
          connectivityService: mockConnectivityService,
        ),
      ),
    );
  }

  testWidgets('Displays movie details when online', (
    WidgetTester tester,
  ) async {
    final movie = Movie(
      id: 1,
      title: 'Interstellar',
      overview: 'A team of explorers travel through a wormhole in space.',
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
    );

    final movieDetails = MovieDetails(
      id: 1,
      title: 'Interstellar',
      overview: 'A team of explorers travel through a wormhole in space.',
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
    );

    when(
      () => mockMovieDetailsBloc.state,
    ).thenReturn(MovieDetailsLoadedState(movieDetails: movieDetails));
    when(
      () => mockFavoriteMovieBloc.state,
    ).thenReturn(FavoriteMovieCheckedState(movieId: 1, isFavorite: false));

    await tester.pumpWidget(createWidgetUnderTest(movie));
    await tester.pumpAndSettle();

    expect(find.text('Interstellar'), findsOneWidget);
    expect(
      find.text('A team of explorers travel through a wormhole in space.'),
      findsOneWidget,
    );
    expect(find.text('Release Date: 2014-11-07'), findsOneWidget);
    expect(find.text('Rating: 8.6'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('Displays "No Internet Connection" when offline', (
    WidgetTester tester,
  ) async {
    final movie = Movie(
      id: 1,
      title: 'Interstellar',
      overview: 'A team of explorers travel through a wormhole in space.',
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
    );

    final movieDetails = MovieDetails(
      id: 1,
      title: 'Interstellar',
      overview: 'A team of explorers travel through a wormhole in space.',
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
    );

    when(
      () => mockConnectivityService.isConnected(),
    ).thenAnswer((_) async => false);
    when(
      () => mockMovieDetailsBloc.state,
    ).thenReturn(MovieDetailsLoadedState(movieDetails: movieDetails));
    when(
      () => mockFavoriteMovieBloc.state,
    ).thenReturn(FavoriteMovieCheckedState(movieId: 1, isFavorite: false));

    await tester.pumpWidget(createWidgetUnderTest(movie));
    await tester.pumpAndSettle();

    expect(find.text('No Internet Connection'), findsOneWidget);
    expect(find.text('Interstellar'), findsNothing);
  });
}
