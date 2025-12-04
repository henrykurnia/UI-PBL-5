import 'package:hydrosee/models/location_model.dart';
import 'package:hydrosee/models/current_weather_model.dart';
import 'package:hydrosee/models/daily_weather_model.dart';
import 'package:hydrosee/models/hourly_weather_model.dart';

class FullWeatherModel {
  final LocationModel location;
  final CurrentWeatherModel current;
  final List<DailyForecastModel> dailyForecasts;
  final List<HourlyForecastModel> hourlyForecasts;

  FullWeatherModel({
    required this.location,
    required this.current,
    required this.dailyForecasts,
    required this.hourlyForecasts,
  });

  factory FullWeatherModel.fromJson(Map<String, dynamic> json) {
    // Ambil sub-map 'forecast' yang berisi semua data cuaca (current, daily, hourly)
    final forecastData = json["forecast"] as Map<String, dynamic>?;

    // --- 1. PARSING LOKASI (Berada di level atas JSON, BUKAN LIST) ---
    final locationData = json["location"] as Map<String, dynamic>?;

    final LocationModel parsedLocation =
        locationData != null
            ? LocationModel.fromJson(locationData)
            : LocationModel(city: "N/A", state: "N/A");

    // Jika 'forecast' tidak ada, kita tidak bisa mem-parsing data cuaca.
    if (forecastData == null) {
      return FullWeatherModel(
        location: parsedLocation,
        current: CurrentWeatherModel(
            temperatureC: 0.0, condition: "N/A", humidity: 0.0, windSpeedMps: 0.0),
        dailyForecasts: [],
        hourlyForecasts: [],
      );
    }
    
    // --- 2. PARSING CUACA SAAT INI (DARI forecast['current']) ---
    final currentJson = forecastData["current"] as Map<String, dynamic>?;
    final CurrentWeatherModel parsedCurrent =
        currentJson != null
            ? CurrentWeatherModel.fromJson(currentJson)
            : CurrentWeatherModel(
                temperatureC: 0.0, condition: "N/A", humidity: 0.0, windSpeedMps: 0.0);

    // --- 3. PARSING PREDIKSI HARIAN (LIST DARI forecast['daily']) ---
    final dailyList = forecastData["daily"] as List<dynamic>?;
    final List<DailyForecastModel> parsedDaily = dailyList != null
        ? dailyList
            .map((i) => DailyForecastModel.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    // --- 4. PARSING PREDIKSI PER JAM (LIST DARI forecast['hourly']) ---
    final hourlyList = forecastData["hourly"] as List<dynamic>?;
    final List<HourlyForecastModel> parsedHourly = hourlyList != null
        ? hourlyList
            .map((i) => HourlyForecastModel.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    // --- RETURN SEMUA DATA DALAM SATU OBJECT ---
    return FullWeatherModel(
      location: parsedLocation,
      current: parsedCurrent,
      dailyForecasts: parsedDaily,
      hourlyForecasts: parsedHourly,
    );
  }
}