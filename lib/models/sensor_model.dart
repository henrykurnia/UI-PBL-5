class SensorModel {
  final String temp;
  final String hum;

  SensorModel({
    required this.temp,
    required this.hum,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      temp: json["temp"] ?? "N/A",
      hum: json["hum"] ?? "N/A",
    );
  }
}
