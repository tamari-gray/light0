import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/db.dart';
import 'package:light0/services/location.dart';

class PlayingGame extends StatefulWidget {
  const PlayingGame({Key key}) : super(key: key);

  @override
  _PlayingGameState createState() => _PlayingGameState();
}

class _PlayingGameState extends State<PlayingGame> {
  String _gameState;

  @override
  void initState() {
    // TODO: implement initState
    _gameState = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text("game screen"),
          leading: IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(height: 350, child: InGameMap()),
              _gameState == "initialising" ? Container() : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

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

class InitCountdown extends StatefulWidget {
  @override
  _InitCountdownState createState() => _InitCountdownState();
}

class _InitCountdownState extends State<InitCountdown> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
