import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_event.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/blocs/movie_details/movie_details_bloc.dart';
import 'package:stage/blocs/movie_details/movie_details_event.dart';
import 'package:stage/blocs/movie_details/movie_details_state.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/services/connectivity_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final ConnectivityService connectivityService;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.connectivityService,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    context.read<MovieDetailsBloc>().add(
      LoadMovieDetailsEvent(movieId: widget.movie.id!),
    );
    context.read<FavoriteMovieBloc>().add(
      CheckFavoriteMovieEvent(movieId: widget.movie.id!),
    );
  }

  Future<void> _initializeConnectivity() async {
    isOffline = !(await widget.connectivityService.isConnected());
    setState(() {});

    widget.connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        isOffline = !isConnected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isOffline) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movie Details')),
        body: const Center(
          child: Text(
            'No Internet Connection',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
        actions: [
          BlocBuilder<FavoriteMovieBloc, FavoriteMovieState>(
            builder: (context, state) {
              bool isFavorite = false;
              if (state is FavoriteMovieCheckedState &&
                  state.movieId == widget.movie.id!) {
                isFavorite = state.isFavorite;
              }
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (isFavorite) {
                    context.read<FavoriteMovieBloc>().add(
                      RemoveFavoriteMovieEvent(movieId: widget.movie.id!),
                    );
                  } else {
                    context.read<FavoriteMovieBloc>().add(
                      AddFavoriteMovieEvent(movie: widget.movie),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieDetailsLoadedState) {
            final movieDetails = state.movieDetails;
            return ListView(
              children: [
                widget.movie.posterPath != null
                    ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w500${movieDetails.posterPath}',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.error, size: 50),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        color: Colors.grey[300], // Placeholder background color
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey, // Placeholder icon color
                        ),
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieDetails.title ?? 'Unknown Title',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movieDetails.overview ?? 'No overview available.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Release Date: ${movieDetails.releaseDate ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rating: ${movieDetails.voteAverage?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is MovieDetailsErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No details available.'));
          }
        },
      ),
    );
  }
}
