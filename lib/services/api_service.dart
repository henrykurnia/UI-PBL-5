import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Tambahkan ini
import '../config/firebase_config.dart';

class ApiService {
  static const String baseUrl = FirebaseConfig.backendUrl;

  // =======================================================================
  // FITUR LAMA (CUACA & AUTH)
  // =======================================================================

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

  // =======================================================================
  // ✅ FITUR BARU: MANAJEMEN PERANGKAT IOT
  // =======================================================================

  /// Mendaftarkan device baru ke Backend Flask
  static Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String deviceName,
    String deviceType = 'sensor',
  }) async {
    try {
      // 1. Ambil User & ID Token dari Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User belum login');
      
      final String? idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Gagal mengambil ID Token');

      // 2. Siapkan URL (Sesuaikan dengan blueprint di Flask Anda)
      // Asumsi: blueprint Anda di Flask di-register dengan url_prefix='/api/iot_device'
      final Uri url = Uri.parse('$baseUrl/api/iot_device/register');

      // 3. Kirim Request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Kirim token di header
        },
        body: jsonEncode({
          'idToken': idToken, // Kirim juga di body jika backend membutuhkannya dari body
          'deviceId': deviceId,
          'deviceName': deviceName,
          'deviceType': deviceType,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Gagal mendaftarkan perangkat');
      }
    } catch (e) {
      // Lempar error agar bisa ditangkap oleh UI (Try-Catch di add_device.dart)
      throw Exception('Gagal koneksi ke server: $e');
    }
  }

  /// Menghapus device melalui Backend Flask
  static Future<bool> deleteDevice(String deviceId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User belum login');

      final String? idToken = await user.getIdToken();
      
      final Uri url = Uri.parse('$baseUrl/api/iot_device/delete/$deviceId');
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $idToken', 
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting device: $e");
      return false; // Kembalikan false jika gagal
    }
  }
}