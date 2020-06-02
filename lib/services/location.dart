import 'dart:async';

import 'package:light0/models/userLocation.dart';
import 'package:location/location.dart';

class LocationService {
  UserLocation _currentLocation;

  Location location = Location();

  // listen to realtime location
  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>.broadcast();

  locationService() {
    location.requestPermission().then((PermissionStatus status) {
      if (status == PermissionStatus.granted) {
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            print("accuracy: ${locationData.accuracy}");
            _locationController.add(
              UserLocation(
                  latitude: locationData.latitude,
                  longitude: locationData.longitude),
            );
          }
        });
      }
    });
  }

  Stream<UserLocation> get locationStream => _locationController.stream;

  //  get location once
  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
          latitude: userLocation.latitude, longitude: userLocation.longitude);
    } catch (e) {
      print('error getting user location: $e');
    }

    return _currentLocation;
  }
}
