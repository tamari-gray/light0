import 'package:flutter/material.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/services/db.dart';
import 'package:light0/services/items.dart';
import 'package:provider/provider.dart';

import 'package:light0/models/userData.dart';
import 'package:countdown_flutter/countdown_flutter.dart';

class RadarTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<UserData>(context);
    final _gameData = Provider.of<GameData>(context);
    if (_userData != null && _gameData != null)
      return Center(
        child: CountdownFormatted(
          duration: Duration(minutes: 5),
          onFinish: () {
            // reset items => position, erase items from players
            // if(_userData.isTagger) DbService().radar

            // show players location to tagger

            //
          },
          builder: (BuildContext ctx, String remaining) {
            if (remaining == "05:00" && _userData.isTagger)
              ItemsService().generateNewItems(_gameData);

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
