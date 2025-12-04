// lib/models/hourly_weather_model.dart

class HourlyForecastModel {
  final DateTime timestamp; // Ubah jadi DateTime
  final double temperatureC;
  final String condition;

  HourlyForecastModel({
    required this.timestamp,
    required this.temperatureC,
    required this.condition,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    // Ambil 'dt' (detik) dan ubah ke milliseconds (* 1000) untuk jadi DateTime
    final int dt = (json["dt"] as num?)?.toInt() ?? 0;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);

    // Parsing Suhu (Kelvin -> Celsius)
    final double kelvin = (json["temp"] as num?)?.toDouble() ?? 0.0;
    final double tempC = kelvin - 273.15;

    // Parsing Kondisi
    final List<dynamic>? weather = json['weather'];
    final String cond = weather != null && weather.isNotEmpty
        ? weather[0]['description'] ?? "N/A"
        : "N/A";

    return HourlyForecastModel(
      timestamp: date, // Simpan sebagai DateTime
      temperatureC: tempC,
      condition: cond,
    );
  }
}