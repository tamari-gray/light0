import 'package:flutter/material.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/db.dart';
import 'package:light0/screens/playingGame.dart';
import 'package:provider/provider.dart';

class Lobby extends StatefulWidget {
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final AuthService _auth = AuthService();
  Color color;
  String tagger;

  @override
  void initState() {
    super.initState();
    color = Colors.transparent;
    tagger = "";
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(username: "");
    final _players = Provider.of<List<String>>(context) != null
        ? Provider.of<List<String>>(context)
        : [""];

    final _snackBar = SnackBar(
      content: Text('choose a tagger'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${_userData.username}"),
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
                            ? Text("${_players[index]} is the tagger")
                            : Text("${_players[index]} has joined"),
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
                                tagger = "";
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
                        onPressed: () {
                          tagger == ""
                              ? Scaffold.of(context).showSnackBar(_snackBar)
                              : _showMyDialog(_user.userId);
                        },
                        child: Text("start game"),
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

  Future<void> _showMyDialog(String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you ready?'),
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: <Widget>[
          //       Text('Are you ready?'),
          //     ],
          //   ),
          // ),
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
