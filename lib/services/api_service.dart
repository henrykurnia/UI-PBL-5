import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class ApiService {
  static const String baseUrl = FirebaseConfig.backendUrl;

  static Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/weather/post'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lat": lat,
          "lon": lon,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      print("Weather error: ${response.body}");
      return null;
    } catch (e) {
      print("Weather exception: $e");
      return null;
    }
  }


  // Verify token with backend
  Future<bool> verifyToken(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error verifying token: $e');
      return false;
    }
  }

  // Example: Call protected endpoint
  Future<Map<String, dynamic>?> getProtectedData(String idToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/some-protected-endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      print("API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error calling API: $e');
      return null;
    }
  }
}
