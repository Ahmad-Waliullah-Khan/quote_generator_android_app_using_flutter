// motivation_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationApi {
  final String quoteApiUrl;
  final String unsplashAccessKey;

  MotivationApi({required this.quoteApiUrl, required this.unsplashAccessKey});

  Future<Map<String, dynamic>> fetchMotivationalData() async {
    try {
      final response = await http.get(
        Uri.parse(quoteApiUrl),
        headers: {'X-Api-Key': '6qfLVQ9EP7D1oDw+JX1rvQ==q9pAOySKsn18XRAW'}, // Replace with your actual API key
      );

      if (response.statusCode == 200) {
        final motivationalData = response.body;
        return parseMotivationalData(motivationalData);
      } else {
        throw Exception('Failed to load motivational data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motivational data: $e');
      return {};
    }
  }

  Map<String, dynamic> parseMotivationalData(String motivationalData) {
    final data = json.decode(motivationalData);
    return {'quote': data[0]['quote'], 'author': data[0]['author']};
  }

  Future<String> fetchRandomImageUrl({String query = 'inspirational'}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/photos/random?query=$query&count=1'),
        headers: {
          'Authorization': 'Client-ID $unsplashAccessKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[0]['urls']['regular'] ?? ''; // Assuming the URL is in the 'regular' field
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random image: $e');
      return ''; // Return an empty string on error
    }
  }
}
