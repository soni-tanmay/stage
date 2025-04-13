import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_bloc.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_event.dart';
import 'package:stage/blocs/favorite_movie/favorite_movie_state.dart';
import 'package:stage/models/movie_list_model.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  void _checkIfFavorite() {
    context.read<FavoriteMovieBloc>().add(
      CheckFavoriteMovieEvent(movieId: widget.movie.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteMovieBloc, FavoriteMovieState>(
      listener: (context, state) {
        if (state is FavoriteMovieCheckedState &&
            state.movieId == widget.movie.id) {
          setState(() {
            isFavorite = state.isFavorite;
          });
        } else if (state is FavoriteMovieAddedState &&
            state.movie.id == widget.movie.id) {
          _checkIfFavorite();
        } else if (state is FavoriteMovieRemovedState &&
            state.movieId == widget.movie.id) {
          _checkIfFavorite();
        }
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          children: [
            Expanded(
              child:
                  widget.movie.posterPath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                      : Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.movie.title ?? 'Unknown Title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
