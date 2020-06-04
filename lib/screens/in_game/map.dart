import 'dart:collection';
import 'dart:math';

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
  Set<Marker> _items = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();

  UserLocation _myLocation;
  LatLng _itemLocation;

  double boundaryRadius;

  @override
  void initState() {
    boundaryRadius = 250;
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
          radius: boundaryRadius,
          strokeWidth: 3,
          strokeColor: Color.fromRGBO(102, 51, 153, 1),
          fillColor: Color.fromRGBO(102, 51, 153, 0.3),
          zIndex: 1,
        ),
      );

      setState(() {
        _itemLocation = position;
      });

      _setItems(position);
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

  void _setItems(LatLng point) {
    double x0 = point.latitude;
    double y0 = point.longitude;
    Random randomPoint = new Random();

    // radius to degrees
    double radiusInDegrees = boundaryRadius / 111000;

    // calcliations
    double u = randomPoint.nextDouble();
    double v = randomPoint.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t);

    double newX = x / cos(y0);
    double foundLongitude = newX + x0;
    double foundLatitude = y + y0;

    print("new item coords: $foundLatitude, $foundLongitude");

    // test for random position item

    // Set<Marker> _newItems = HashSet<Marker>();

    // _newItems.add(
    //   Marker(
    //     markerId: MarkerId("yeet"),
    //     position: LatLng(foundLongitude, foundLatitude),
    //   ),
    // );

    // setState(() {
    // _itemLocation = LatLng(foundLongitude, foundLatitude);
    // _items = _newItems;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _myLocation != null
                ? LatLng(_myLocation.latitude, _myLocation.longitude)
                : LatLng(0, 0),
            zoom: 17,
          ),
          circles: _circles,
          markers: _items,
          myLocationEnabled: true,
        ),
        // RaisedButton( // test for show random items reset
        //   onPressed: () {
        //     _setItems(_itemLocation);
        //     _mapController.moveCamera(
        //       CameraUpdate.newLatLng(_itemLocation),
        //     );
        //   },
        //   child: Text("show item"),
        // )
      ],
    );
  }
}
