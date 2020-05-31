import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:light0/services/db.dart';
import 'package:light0/screens/playingGame.dart';
import 'package:light0/models/user.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SetBoundary extends StatefulWidget {
  @override
  _SetBoundaryState createState() => _SetBoundaryState();
}

class _SetBoundaryState extends State<SetBoundary> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Hold and drag to reposition"),
        actions: <Widget>[],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Map(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                child: RaisedButton(
                  onPressed: () {
                    _showMyDialog(_user.userId);
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

  Future<void> _showMyDialog(String userId) async {
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayingGame(),
                          ),
                        );
                        await DbService(userId: userId).initialiseGame();
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
}

class _MapState extends State<Map> {
  GoogleMapController _mapController;
  Set<Marker> _markers = HashSet<Marker>();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("boundary"),
          position: LatLng(-37.867512, 144.978973),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(-37.867512, 144.978973),
        zoom: 17,
      ),
      markers: _markers,
    );
  }
}
