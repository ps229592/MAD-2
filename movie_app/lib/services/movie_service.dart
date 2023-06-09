import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/movie.dart';

class MovieService {
  static const String apiUrl = 'http://10.0.2.2:8000/api/movies';

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      return jsonData.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  Future<Movie> createMovie(Movie movie) async {
    final response =
        await http.post(Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': movie.title,
              'year': movie.year,
            }));

    if (response.statusCode != 201) {
      throw Exception('Failed to create movie');
    }

    final result = jsonDecode(response.body);
    return Movie(
        id: result['id'], title: result['title'], year: result['year']);
  }

  Future<void> updateMovie(Movie movie) async {
    final url = Uri.parse('$apiUrl/${movie.id}');
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': movie.title,
        'year': movie.year,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update movie');
    }
  }

  Future<void> deleteMovie(int movieId) async {
    final url = Uri.parse('$apiUrl/$movieId');
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete movie');
    }
  }
}
