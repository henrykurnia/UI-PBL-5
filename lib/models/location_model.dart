// lib/models/location_model.dart
class LocationModel {
  final String city;
  final String state;

  LocationModel({
    required this.city,
    required this.state,
  });

  // Menerima Map dari json['location']
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      city: json["city"] ?? "N/A",
      state: json["state"] ?? "N/A",
    );
  }
}