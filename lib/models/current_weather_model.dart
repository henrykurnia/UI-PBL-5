// lib/models/current_weather_model.dart

// Fungsi helper untuk konversi Kelvin ke Celsius
double _kelvinToCelsius(double kelvin) {
  // Hanya berlaku jika kelvin lebih besar dari titik beku air (273.15 K)
  if (kelvin > 273.15) {
    return kelvin - 273.15;
  }
  return 0.0; // Mengembalikan 0 jika data Kelvin tidak valid
}

class CurrentWeatherModel {
  final double temperatureC; // Diubah namanya menjadi temperatureC (Celsius)
  final String condition;
  final double humidity;
  final double windSpeedMps; // Diubah namanya menjadi windSpeedMps (m/s)

  CurrentWeatherModel({
    required this.temperatureC,
    required this.condition,
    required this.humidity,
    required this.windSpeedMps,
  });

  // Factory constructor menerima Map yang HANYA berisi data "current" di JSON
  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    // Parsing Suhu (Kelvin -> Celsius)
    final double kelvinTemp = (json["temp"] as num?)?.toDouble() ?? 0.0;
    
    // Parsing Kondisi Cuaca (berada di dalam list 'weather')
    final List<dynamic>? weatherArray = json['weather'];
    final String description = weatherArray != null && weatherArray.isNotEmpty
        ? weatherArray[0]['description'] ?? "N/A"
        : "N/A";
    
    // Parsing Kecepatan Angin (wind_speed dalam m/s)
    final double windSpeed = (json["wind_speed"] as num?)?.toDouble() ?? 0.0;
    
    // Parsing Kelembaban
    final double humidityValue = (json["humidity"] as num?)?.toDouble() ?? 0.0;


    return CurrentWeatherModel(
      // Konversi Kelvin ke Celsius
      temperatureC: _kelvinToCelsius(kelvinTemp), 
      // Menggunakan 'description' dari list 'weather'
      condition: description, 
      // Menggunakan data 'humidity'
      humidity: humidityValue, 
      // Menggunakan 'wind_speed' (m/s)
      windSpeedMps: windSpeed, 
    );
  }
}