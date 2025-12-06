class DailyForecastModel {
  final DateTime timestamp;
  final double maxTemperatureC; // Suhu Tertinggi
  final double minTemperatureC; // Suhu Terendah
  final double tempAvg;         // Suhu Rata-rata Siang (Opsional, buat display utama)
  final String condition;       // Deskripsi (cth: "hujan rintik-rintik")
  final int humidity;           // Kelembapan

  DailyForecastModel({
    required this.timestamp,
    required this.maxTemperatureC,
    required this.minTemperatureC,
    required this.tempAvg,
    required this.condition,
    required this.humidity,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    // 1. Ambil Timestamp
    final int dt = (json["dt"] as num?)?.toInt() ?? 0;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);

    // 2. Ambil Objek Temp
    final tempMap = json['temp'];
    double maxK = 0.0, minK = 0.0, dayK = 0.0;
    
    if (tempMap != null) {
      maxK = (tempMap["max"] as num?)?.toDouble() ?? 0.0;
      minK = (tempMap["min"] as num?)?.toDouble() ?? 0.0;
      dayK = (tempMap["day"] as num?)?.toDouble() ?? 0.0;
    }

    // 3. Ambil Deskripsi Cuaca
    final List<dynamic>? weather = json['weather'];
    final String cond = weather != null && weather.isNotEmpty
        ? weather[0]['description'] ?? "N/A"
        : "N/A";

    return DailyForecastModel(
      timestamp: date,
      // Konversi Kelvin ke Celsius (-273.15)
      maxTemperatureC: maxK - 273.15,
      minTemperatureC: minK - 273.15,
      tempAvg: dayK - 273.15, 
      condition: cond,
      humidity: (json["humidity"] as num?)?.toInt() ?? 0,
    );
  }
}