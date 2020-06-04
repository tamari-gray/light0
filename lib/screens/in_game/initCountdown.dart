import 'package:flutter/material.dart';
import 'package:light0/services/db.dart';
import 'package:provider/provider.dart';

import 'package:light0/models/userData.dart';
import 'package:light0/models/user.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

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
