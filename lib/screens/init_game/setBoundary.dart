import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/db.dart';
import 'package:light0/screens/in_game/playingGame.dart';
import 'package:light0/models/user.dart';
import 'package:light0/services/location.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SetBoundary extends StatefulWidget {
  @override
  _SetBoundaryState createState() => _SetBoundaryState();
}

class _SetBoundaryState extends State<SetBoundary> {
  LatLng _boundaryPosition;

  _setBoundaryPosition(LatLng newPosition) {
    setState(() {
      print("updating boundary position from map: ${newPosition.latitude}");
      _boundaryPosition = newPosition;
    });
  }

  @override
  void initState() {
    _boundaryPosition = LatLng(0, 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Reposition boundary"),
        actions: <Widget>[],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Map(setBoundaryPosition: _setBoundaryPosition),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                child: RaisedButton(
                  onPressed: () {
                    _showMyDialog(_user.userId, _boundaryPosition);
                  },
                  child: Text("start game"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String userId, LatLng boundaryPosition) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap back
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you ready?'),
          actions: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
                    child: RaisedButton(
                      child: Text("Start game"),
                      onPressed: () async {
                        await DbService(userId: userId).initialiseGame();
                        await DbService(userId: userId)
                            .setBoundary(boundaryPosition);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayingGame(),
                          ),
                        );
                      },
                    ),
                  ),
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ])
          ],
        );
      },
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();

  final Function(LatLng) setBoundaryPosition;

  Map({this.setBoundaryPosition});
}

class _MapState extends State<Map> {
  GoogleMapController _mapController;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();

  UserLocation _myLocation;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  _getLocation() async {
    await LocationService().getLocation().then((value) {
      setState(() {
        _myLocation = value;
      });
      _setBoundary(LatLng(value.latitude, value.longitude));
      widget.setBoundaryPosition(LatLng(value.latitude, value.longitude));
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

  void _setBoundary(LatLng location) {
    _circles.add(
      Circle(
        circleId: CircleId("0"),
        center: location,
        radius: 250,
        strokeWidth: 3,
        strokeColor: Color.fromRGBO(102, 51, 153, 1),
        fillColor: Color.fromRGBO(102, 51, 153, 0.3),
        zIndex: 1,
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: location,
        draggable: true,
        zIndex: 2,
        onDragEnd: ((value) {
          //set new boundary location
          Set<Circle> newCircles = HashSet<Circle>();

          final LatLng newBoundaryPosition =
              LatLng(value.latitude, value.longitude);

          newCircles.add(
            Circle(
              circleId: CircleId("0"),
              center: newBoundaryPosition,
              radius: 250,
              strokeWidth: 3,
              strokeColor: Color.fromRGBO(102, 51, 153, 1),
              fillColor: Color.fromRGBO(102, 51, 153, 0.3),
              zIndex: 1,
            ),
          );
          setState(() {
            _circles = newCircles;
            widget.setBoundaryPosition(newBoundaryPosition);
          });
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _myLocation != null
            ? LatLng(_myLocation.latitude, _myLocation.longitude)
            : LatLng(0, 0),
        zoom: 16,
      ),
      circles: _circles,
      markers: _markers,
      myLocationEnabled: true,
    );
  }
}
