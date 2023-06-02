import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movies_app/models/trailer.dart';
import 'package:movies_app/models/movie.dart';
import 'package:movies_app/services/authentication_services.dart';

class TrailerService {
  static const String apiUrl = 'http://10.0.2.2:8000/api/trailers';

  Future<Trailer> createTrailer(Trailer trailer, Movie movie) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthenticationServices.bearerToken}',
      },
      body: jsonEncode({
        'title': trailer.title,
        'url': trailer.url,
        'movie_id': movie.id,
      }),
    );

    print(movie.id);

    if (response.statusCode == 201) {
      final result = jsonDecode(response.body)['data'];
      final newToken = jsonDecode(response.body)['access_token'];
      AuthenticationServices.updateBearerToken(newToken);
      return Trailer(
        id: result['id'],
        title: result['title'],
        url: result['url'],
      );
    } else {
      throw Exception('Failed to create trailer');
    }
  }

  // Future<void> updateMovie(Movie movie) async {
  //   final url = Uri.parse('$apiUrl/${movie.id}');
  //   final response = await http.put(
  //     url,
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${AuthenticationServices.bearerToken}',
  //     },
  //     body: jsonEncode({
  //       'title': movie.title,
  //       'year': movie.year,
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final newToken = jsonDecode(response.body)['access_token'];
  //     AuthenticationServices.updateBearerToken(newToken);
  //   } else {
  //     throw Exception('Failed to update movie');
  //   }
  // }

  // Future<void> deleteMovie(int movieId) async {
  //   final url = Uri.parse('$apiUrl/$movieId');
  //   final response = await http.delete(
  //     url,
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${AuthenticationServices.bearerToken}',
  //     },
  //   );

  //   if (response.statusCode == 202) {
  //     final newToken = jsonDecode(response.body)['access_token'];
  //     AuthenticationServices.updateBearerToken(newToken);
  //   } else {
  //     throw Exception('Failed to delete movie');
  //   }
  // }
}
