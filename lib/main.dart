import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/movie_details/movie_details_bloc.dart';
import 'package:stage/services/connectivity_service.dart';
import 'package:stage/services/local_db_service.dart';
import 'repositories/movie_repository.dart';
import 'blocs/movie_list/movie_list_bloc.dart';
import 'screens/movie_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await LocalDbService().db;

  final movieRepository = MovieRepository();
  final connectivityService = ConnectivityService();

  runApp(
    MyApp(
      movieRepository: movieRepository,
      connectivityService: connectivityService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final MovieRepository movieRepository;
  final ConnectivityService connectivityService;
  const MyApp({
    super.key,
    required this.movieRepository,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieListBloc>(
          create: (context) => MovieListBloc(movieRepository: movieRepository),
        ),
        BlocProvider<MovieDetailsBloc>(
          create:
              (context) => MovieDetailsBloc(movieRepository: movieRepository),
        ),
        BlocProvider<FavoriteMovieBloc>(
          create: (context) => FavoriteMovieBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Stage OTT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
        home: MovieListScreen(connectivityService: connectivityService),
      ),
    );
  }
}
