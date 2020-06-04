import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/db.dart';
import 'package:light0/services/location.dart';

class InGameMap extends StatefulWidget {
  @override
  _InGameMapState createState() => _InGameMapState();
}

class _InGameMapState extends State<InGameMap> {
  GoogleMapController _mapController;
  // Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();

  UserLocation _myLocation;

  @override
  void initState() {
    _getLocation();
    _updateBoundaryPosition();
    super.initState();
  }

  void _getLocation() async {
    await LocationService().getLocation().then((value) {
      setState(() {
        _myLocation = value;
      });
    });
  }

  void _updateBoundaryPosition() async {
    await DbService().getBoundaryPosition.then((LatLng position) {
      print("got boundary position: ${position.latitude}");
      _circles.add(
        Circle(
          circleId: CircleId("boundary"),
          center: position,
          radius: 250,
          strokeWidth: 3,
          strokeColor: Color.fromRGBO(102, 51, 153, 1),
          fillColor: Color.fromRGBO(102, 51, 153, 0.3),
          zIndex: 1,
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // _setMapStyle();
  }

  // void _setMapStyle() async {
  // String style = await DefaultAssetBundle.of(context)
  //     .loadString("assets/map_style.json");
  // _mapController.setMapStyle(style);
  // }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _myLocation != null
            ? LatLng(_myLocation.latitude, _myLocation.longitude)
            : LatLng(0, 0),
        zoom: 17,
      ),
      circles: _circles,
      myLocationEnabled: true,
    );
  }
}
