import 'package:geolocator/geolocator.dart';

import 'package:hydrosee/services/location_status.dart';

// enum LocationStatus {
//   gpsOff,
//   denied,
//   deniedForever,
//   success,
//   error,
// }

class GetLocationUser {
  Future<(LocationStatus, Position?)> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return (LocationStatus.gpsOff, null);
    }

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

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return (LocationStatus.success, pos);
    } catch (e) {
      return (LocationStatus.error, null);
    }
  }

}
