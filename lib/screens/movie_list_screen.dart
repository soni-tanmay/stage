import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_event.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/blocs/movie_list/movie_list_bloc.dart';
import 'package:stage/blocs/movie_list/movie_list_event.dart';
import 'package:stage/blocs/movie_list/movie_list_state.dart';
import 'package:stage/models/movie_list_model.dart';
import 'package:stage/screens/movie_detail_screen.dart';
import 'package:stage/services/connectivity_service.dart';
import 'package:stage/widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  final ConnectivityService connectivityService;
  const MovieListScreen({super.key, required this.connectivityService});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  bool isLoadingMore = false;
  bool showFavoritesOnly = false;
  bool isOffline = false;
  List<Movie> displayList = [];
  List<Movie> movieList = [];
  List<Movie> favoriteMoviesList = [];

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        final state = context.read<MovieListBloc>().state;
        if (!showFavoritesOnly &&
            !isOffline &&
            _searchController.text.trim().isEmpty &&
            state is MovieListLoadedState &&
            state.isLoadingMore) {
          isLoadingMore = true;
          currentPage += 1;
          context.read<MovieListBloc>().add(
            LoadMoviesListEvent(page: currentPage),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    isOffline = !(await widget.connectivityService.isConnected());
    if (isOffline) {
      setState(() {
        showFavoritesOnly = true;
      });
      context.read<FavoriteMovieBloc>().add(LoadFavoriteMoviesEvent());
    } else {
      context.read<MovieListBloc>().add(LoadMoviesListEvent(page: currentPage));
    }

    widget.connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        isOffline = !isConnected;
        if (isOffline) {
          showFavoritesOnly = true;
          context.read<FavoriteMovieBloc>().add(LoadFavoriteMoviesEvent());
        } else {
          showFavoritesOnly = false;
          context.read<MovieListBloc>().add(
            LoadMoviesListEvent(page: currentPage),
          );
        }
      });
    });
  }

  void _navigateToDetails(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MovieDetailScreen(
              movie: movie,
              connectivityService: widget.connectivityService,
            ),
      ),
    );
  }

  void _filterMovies(String query) {
    if (query.isNotEmpty) {
      setState(() {
        displayList =
            displayList.where((movie) {
              return movie.title != null &&
                  movie.title!.toLowerCase().contains(query.toLowerCase());
            }).toList();
      });
    } else {
      setState(() {
        displayList = movieList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (value) {
            final query = _searchController.text.trim();
            _filterMovies(query);
          },
        ),
        actions: [
          isOffline
              ? IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {},
              )
              : IconButton(
                icon: Icon(
                  showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  color: showFavoritesOnly ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (showFavoritesOnly) {
                    setState(() {
                      _searchController.clear();
                      showFavoritesOnly = false;
                      displayList = movieList;
                    });
                  } else {
                    setState(() {
                      _searchController.clear();
                      showFavoritesOnly = true;
                    });
                    context.read<FavoriteMovieBloc>().add(
                      LoadFavoriteMoviesEvent(),
                    );
                  }
                },
              ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MovieListBloc, MovieListState>(
            listener: (context, state) {
              if (state is MovieListLoadedState) {
                setState(() {
                  movieList.addAll(state.movieList);
                  displayList = movieList;
                  isLoadingMore = false;
                });
              } else if (state is MovieListErrorState) {
                setState(() {
                  isLoadingMore = false;
                });
              }
            },
          ),
          BlocListener<FavoriteMovieBloc, FavoriteMovieState>(
            listener: (context, state) {
              if (state is FavoriteMovieLoadedState) {
                setState(() {
                  favoriteMoviesList = state.favoriteMovies;
                  if (showFavoritesOnly) {
                    displayList = favoriteMoviesList;
                  }
                });
              }
            },
          ),
        ],
        child:
            showFavoritesOnly
                ? BlocBuilder<FavoriteMovieBloc, FavoriteMovieState>(
                  builder: (context, state) {
                    if (state is FavoriteMovieLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FavoriteMovieErrorState) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else {
                      if (displayList.isEmpty) {
                        return const Center(child: Text('No movies found.'));
                      }
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final movie = displayList[index];
                          return GestureDetector(
                            onTap: () {
                              if (movie.id != null) {
                                _navigateToDetails(context, movie);
                              }
                            },
                            child: MovieCard(movie: movie),
                          );
                        },
                      );
                    }
                  },
                )
                : BlocBuilder<MovieListBloc, MovieListState>(
                  builder: (context, state) {
                    if (state is MovieListLoadingState && currentPage == 1) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MovieListErrorState) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else {
                      if (displayList.isEmpty) {
                        return const Center(child: Text('No movies found.'));
                      }
                      return GridView.builder(
                        controller: _scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: displayList.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < displayList.length) {
                            final movie = displayList[index];
                            return GestureDetector(
                              onTap: () {
                                if (movie.id != null) {
                                  _navigateToDetails(context, movie);
                                }
                              },
                              child: MovieCard(movie: movie),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
      ),
    );
  }
}
