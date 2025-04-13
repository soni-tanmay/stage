import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/blocs/movie_list/movie_list_bloc.dart';
import 'package:stage/blocs/movie_list/movie_list_state.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/screens/movie_list_screen.dart';
import 'package:stage/screens/movie_detail_screen.dart';
import 'package:stage/services/connectivity_service.dart';

class MockMovieListBloc extends Mock implements MovieListBloc {}

class MockFavoriteMovieBloc extends Mock implements FavoriteMovieBloc {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMovieListBloc mockMovieListBloc;
  late MockFavoriteMovieBloc mockFavoriteMovieBloc;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockMovieListBloc = MockMovieListBloc();
    mockFavoriteMovieBloc = MockFavoriteMovieBloc();
    mockConnectivityService = MockConnectivityService();

    when(
      () => mockConnectivityService.isConnected(),
    ).thenAnswer((_) async => true);
    when(
      () => mockConnectivityService.connectionStatus,
    ).thenAnswer((_) => const Stream<bool>.empty());
  });

  testWidgets('MovieListScreen integration test', (WidgetTester tester) async {
    final mockMovies = [
      Movie(id: 1, title: 'Interstellar'),
      Movie(id: 2, title: 'Inception'),
    ];

    whenListen(
      mockMovieListBloc,
      Stream.fromIterable([
        MovieListLoadingState(),
        MovieListLoadedState(movieList: mockMovies, isLoadingMore: false),
      ]),
      initialState: MovieListInitialState(),
    );

    whenListen(
      mockFavoriteMovieBloc,
      Stream.fromIterable([
        FavoriteMovieLoadedState(favoriteMovies: [mockMovies[1]]),
      ]),
      initialState: FavoriteMovieInitialState(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MovieListBloc>.value(value: mockMovieListBloc),
            BlocProvider<FavoriteMovieBloc>.value(value: mockFavoriteMovieBloc),
          ],
          child: MovieListScreen(connectivityService: mockConnectivityService),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/movieDetail') {
            final movie = settings.arguments as Movie;
            return MaterialPageRoute(
              builder:
                  (_) => MovieDetailScreen(
                    movie: movie,
                    connectivityService: mockConnectivityService,
                  ),
            );
          }
          return null;
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify search field is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify initial movie cards
    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Inception'), findsOneWidget);

    // Simulate search
    await tester.enterText(find.byType(TextField), 'inter');
    await tester.pumpAndSettle();
    expect(find.text('Interstellar'), findsOneWidget);
    expect(find.text('Inception'), findsNothing);
  });
}
