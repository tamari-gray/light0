import 'package:flutter/material.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:provider/provider.dart';
import 'package:light0/models/userData.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

class InitCountdown extends StatefulWidget {
  final InitGame initGameService;
  InitCountdown({@required this.initGameService});
  @override
  _InitCountdownState createState() => _InitCountdownState();
}

class _InitCountdownState extends State<InitCountdown> {
  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(isTagger: false);

    print("I am the tagger: ${_userData.isTagger}");
    return Center(
      child: Countdown(
        duration: Duration(seconds: 3),
        onFinish: () {
          widget.initGameService.startGame();
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
