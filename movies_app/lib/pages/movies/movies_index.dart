import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies_app/pages/login_page.dart';
import 'package:movies_app/services/movie_services.dart';
import 'package:movies_app/models/movie.dart';
import 'package:movies_app/pages/movies/movie_create.dart';
import 'package:movies_app/pages/movies/movie_edit.dart';
import 'package:movies_app/pages/movies/movie_trailers.dart';

class MovieListPage extends StatefulWidget {
  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> _movies = [];
  bool _signedIn = false;

  void setSignedIn(bool signedIn) {
    setState(() {
      _signedIn = signedIn;
      print(_signedIn);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await MovieService().fetchMovies();
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  void _deleteMovie(int movieId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this movie?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await MovieService().deleteMovie(movieId);
                Navigator.pop(context); // Close the dialog
                _fetchMovies(); // Reload the movie list
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies Index'),
        actions: [
          _signedIn
              ? IconButton(
                  onPressed: () {
                    setSignedIn(false);
                  },
                  icon: Icon(Icons.logout),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(setSignedIn: setSignedIn),
                      ),
                    );
                  },
                  icon: Icon(Icons.login),
                ),
        ],
      ),
      body: ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieTrailersPage(
                    movie: movie,
                    signedIn: _signedIn,
                  ),
                ),
              );
            },
            leading: GestureDetector(
              onTap: () {
                _showImageDialog(movie.posterUrl!);
              },
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl!,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            title: Text(movie.title),
            subtitle: Text(movie.year),
            trailing: _signedIn
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieEditPage(
                                updateMovieList: _fetchMovies,
                                movie: movie,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteMovie(movie.id),
                      ),
                    ],
                  )
                : null,
          );
        },
      ),
      floatingActionButton: _signedIn
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieCreatePage(
                      updateMovieList: _fetchMovies,
                    ),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
