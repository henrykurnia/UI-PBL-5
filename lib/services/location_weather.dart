// get_location_user.dart

import 'package:geolocator/geolocator.dart';
import 'package:hydrosee/services/location_status.dart';
import 'package:hydrosee/services/api_service.dart'; // <-- Import API Service
import 'package:hydrosee/models/full_weather_model.dart'; // <-- Import Model Cuaca

// Ganti nama class atau gunakan yang sudah ada, tapi fungsionalitasnya berubah
class LocationWeather { 
  // Mengubah tipe kembalian: (Status, Data Cuaca?)
  Future<(LocationStatus, FullWeatherModel?)> getWeatherByLocation() async {
    // 1. Cek Service GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return (LocationStatus.gpsOff, null);
    }

    // 2. Cek/Minta Izin
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return (LocationStatus.denied, null);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return (LocationStatus.deniedForever, null);
    }

    // 3. Ambil Lokasi
    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return (LocationStatus.error, null);
    }
    
    // 4. Ambil Data Cuaca menggunakan Lokasi
    try {
      final Map<String, dynamic>? data = await ApiService.getWeather(pos.latitude, pos.longitude);

      if (data != null) {
        final FullWeatherModel weather = FullWeatherModel.fromJson(data);
        return (LocationStatus.success, weather);
      } else {
        // Anggap jika data API null sebagai error API, tapi lokasi sukses diambil
        return (LocationStatus.error, null); 
      }
      
    } catch (e) {
      return (LocationStatus.error, null);
    }
  }
}