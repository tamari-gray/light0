import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:light0/models/userData.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

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
                              "Find an item to hide your location on the next radar!")
                          : Container(),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
