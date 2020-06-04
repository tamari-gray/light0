import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/db.dart';
import 'package:light0/services/location.dart';

import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class PlayingGame extends StatefulWidget {
  const PlayingGame({Key key}) : super(key: key);

  @override
  _PlayingGameState createState() => _PlayingGameState();
}

class _PlayingGameState extends State<PlayingGame> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider<UserData>(
            create: (_) => DbService(userId: _user.userId).userData),
        StreamProvider(create: (_) => DbService().gameState),
      ],
      child: GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _gameState = Provider.of<String>(context);
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(isTagger: false);
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Light0"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("info"),
              icon: const Icon(Icons.info),
              onPressed: () async {
                //show dialog with information
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 350,
                // child: InGameMap(),
              ),
              Container(
                child: _gameInfo(_gameState),
              ),
              Container(
                child: RaisedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.my_location),
                  label: _userData.isTagger ? Text("Tag") : Text("Grab"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Container(
                  child: _userData.isTagger
                      ? Text("hold to tag player")
                      : Text("hold to grab item"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _gameInfo(String gameState) {
    if (gameState == "initialising") {
      return InitCountdown();
    } else if (gameState == "playing") {
      return RadarTimer();
    }
  }
}

class RadarTimer extends StatefulWidget {
  @override
  _RadarTimerState createState() => _RadarTimerState();
}

class _RadarTimerState extends State<RadarTimer> {
  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(isTagger: false);
    return Center(
      child: CountdownFormatted(
        duration: Duration(minutes: 5),
        builder: (BuildContext ctx, String remaining) {
          return _userData.isTagger
              ? Text("$remaining until next radar")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                        "$remaining until next radar",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                      child: !_userData.isTagger
                          ? Text(
                              "Go find an item to hide location on the next radar!")
                          : Container(),
                    ),
                  ],
                );
        },
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
    final _user = Provider.of<User>(context);
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(isTagger: false);

    print("am i a tagger: ${_userData.isTagger}");
    return Center(
      child: Countdown(
        duration: Duration(seconds: 3),
        onFinish: () {
          // print('finished!');
          DbService(userId: _user.userId).startGame();
        },
        builder: (BuildContext ctx, Duration remaining) {
          return _userData != null
              ? _userData.isTagger
                  ? Text('Hunt begins in ${remaining.inSeconds} ')
                  : Text('Go hide! Tagger coming in ${remaining.inSeconds}')
              : Container();
        },
      ),
    );
  }
}
