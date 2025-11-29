class WeatherModel {
  final String condition;
  final String description;
  final String name;
  final double temperature;
  final double feelsLike;
  final int humidity;

  WeatherModel({
    required this.condition,
    required this.description,
    required this.name,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weatherList = json["weather"] as List<dynamic>?;

    return WeatherModel(
      condition: weatherList != null && weatherList.isNotEmpty
          ? weatherList[0]["main"] ?? "Unknown"
          : "Unknown",
      description: weatherList != null && weatherList.isNotEmpty
          ? weatherList[0]["description"] ?? "No description"
          : "No description",
      name: (json["name"] ?? 0).toString(),
      temperature: (json["main"]?["temp"] ?? 0).toDouble(),
      feelsLike: (json["main"]?["feels_like"] ?? 0).toDouble(),
      humidity: (json["main"]?["humidity"] ?? 0).toInt(),
    );
  }
}
