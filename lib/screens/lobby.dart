import 'package:flutter/material.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
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
        : UserData();
    final _users = ["pete", "steve"];

    final _username = _userData != null ? _userData.username : "";

    // print(_userData.isAdmin);

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $_username"),
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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: color,
                    child: ListTile(
                      title: tagger == _users[index]
                          ? Text("${_users[index]} is the tagger")
                          : Text("${_users[index]} has joined"),
                      trailing: _userData?.isAdmin == true
                          ? tagger == _users[index]
                              ? Icon(Icons.check_box)
                              : Icon(Icons.check_box_outline_blank)
                          : null,
                      selected: tagger == _users[index],
                      onTap: () {
                        setState(() {
                          if (_userData.isAdmin == true) {
                            tagger = _users[index];
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
                        //start game
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
    );
  }
}
