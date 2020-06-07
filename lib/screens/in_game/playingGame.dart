import 'dart:async';

import 'package:flutter/material.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/screens/in_game/initCountdown.dart';
import 'package:light0/screens/in_game/map.dart';
import 'package:light0/screens/in_game/radarTimer.dart';
import 'package:light0/services/db.dart';
import 'package:light0/services/location.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

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
        StreamProvider<GameData>(create: (_) => DbService().gameData),
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
    final _gameData = Provider.of<GameData>(context) != null
        ? Provider.of<GameData>(context)
        : false;
    // final _gameS
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Light0"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("info"),
              icon: Icon(Icons.info),
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
                child: InGameMap(
                  tagger: _userData.isTagger,
                ),
              ),
              Container(
                child: _gameInfo(_gameState, _userData.isTagger),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _gameInfo(String gameState, bool tagger) {
    if (gameState == "initialising") {
      return InitCountdown();
    } else if (gameState == "playing") {
      return UserAbilities();
    } else if (gameState == "finished") {
      return "hi";
    }
  }
}

class UserAbilities extends StatefulWidget {
  @override
  _UserAbilitiesState createState() => _UserAbilitiesState();
}

class _UserAbilitiesState extends State<UserAbilities> {
  bool _showTimer;
  int _timer;

  @override
  void initState() {
    _timer = 6;
    _showTimer = false;
    _checkPermission();
    _checkIfEnabled();

    super.initState();
  }

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _checkIfEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  _checkPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<UserLocation> _getLocation() async {
    return await location.getLocation().then((LocationData currentLocation) {
      return UserLocation(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
    });
  }

  _startTimer() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _timer = _timer - 1;
      });
      if (_timer == 5) {
        // set ItemPickedUp == "attempting"; => tagger listens to coll and gets notified when attempting == true
        // DbService().attemptTograbItem()

      } else if (_timer == 0) {
        // grab item
        // DbService().grabItem();
      } else if (_timer == -1) {
        setState(() {
          _timer = 6;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      RadarTimer(),
      _timer < 6 ? Text("$_timer") : Text(""),
      Container(
        child: GestureDetector(
          onTapDown: (e) async {
            // geoquery => update item in db : "no items within 5 metres"
            final _currentLocation = await _getLocation();
            final bool _itemDetected =
                await DbService().checkForItem(_currentLocation);

            if (_itemDetected) {
              _startTimer();
            } else {
              final noItemNotification = SnackBar(
                content: Text('No items within 5 metres'),
                action: SnackBarAction(
                    label: "dismiss",
                    onPressed: () {
                      Scaffold.of(context).hideCurrentSnackBar();
                    }),
              );
              Scaffold.of(context).showSnackBar(noItemNotification);
            }
          },
          onTapUp: (e) {
            // check if timer == 0
            // if timer = 0 while onTapDown => give item to player
            // else: player has dropped item => reset in db
          },
          child: RaisedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.my_location),
            label: Text("Grab"),
            animationDuration: Duration(seconds: 5),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Container(
          child: Text("hold to grab item"),
        ),
      )
    ]);
  }
}
