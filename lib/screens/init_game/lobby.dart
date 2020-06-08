import 'package:flutter/material.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/services/db.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/screens/init_game/setBoundary.dart';
import 'package:provider/provider.dart';

class Lobby extends StatefulWidget {
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final AuthService _auth = AuthService();
  Color color;
  UserData tagger;

  @override
  void initState() {
    super.initState();
    color = Colors.transparent;
    tagger = UserData(username: "tagger", userId: "taggerId");
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(username: "", userId: "");
    final _players = Provider.of<List<UserData>>(context) != null
        ? Provider.of<List<UserData>>(context)
        : [UserData(username: "", userId: "")];
    final double _remainingPlayers = _players != null
        ? _players.where((player) => player.isTagger != true).length.toDouble()
        : 0;

    final _snackBar = SnackBar(
      content: Text('choose a tagger'),
    );

    if (_players != null && _userData != null)
      return Scaffold(
        appBar: AppBar(
          title: Text("Welcome"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("leave game"),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await _auth.logout(_user.userId);
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) => Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: color,
                        child: ListTile(
                          title: tagger == _players[index]
                              ? Text(
                                  "${_players[index].username} is the tagger")
                              : Text("${_players[index].username} has joined"),
                          trailing: _userData?.isAdmin == true
                              ? tagger == _players[index]
                                  ? Icon(Icons.check_box)
                                  : Icon(Icons.check_box_outline_blank)
                              : null,
                          selected: tagger == _players[index],
                          onTap: () {
                            setState(() {
                              if (_userData.isAdmin == true) {
                                if (tagger == _players[index]) {
                                  tagger = UserData(
                                      username: "tagger", userId: "taggerId");
                                } else {
                                  tagger = _players[index];
                                }
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                _userData.isAdmin == true
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                        child: RaisedButton(
                          onPressed: () async {
                            if (tagger.userId == "taggerId") {
                              Scaffold.of(context).showSnackBar(_snackBar);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SetBoundary(
                                    remainingPlayers: _remainingPlayers,
                                  ),
                                ),
                              );

                              await DbService().setTagger(tagger);
                            }
                          },
                          child: Text("Set boundary"),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                          child: Text(
                            "Waitng for more players to join..",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
  }
}
