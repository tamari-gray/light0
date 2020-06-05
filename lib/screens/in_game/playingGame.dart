import 'package:flutter/material.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/user.dart';
import 'package:light0/screens/in_game/initCountdown.dart';
import 'package:light0/screens/in_game/map.dart';
import 'package:light0/screens/in_game/radarTimer.dart';
import 'package:light0/services/db.dart';
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
                child: InGameMap(),
              ),
              Container(
                child: _gameInfo(_gameState),
              ),
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
      return UseAbility();
    } else if (gameState == "finished") {
      return "hi";
    }
  }
}

class UseAbility extends StatelessWidget {
  const UseAbility({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(isTagger: false);
    return Column(children: <Widget>[
      RadarTimer(),
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
    ]);
  }
}
