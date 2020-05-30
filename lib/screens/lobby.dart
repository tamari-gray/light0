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
    final _userData = Provider.of<UserData>(context);
    final _users = ["pete", "steve"];

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
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _userData.isAdmin == true
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: color,
                          child: ListTile(
                            title: Text(_users[index]),
                            // selected: _users[index],
                            onTap: () {
                              setState(() {
                                if (color == Colors.transparent) {
                                  color = Colors.blueAccent;
                                  tagger = _users[index];
                                } else {
                                  color = Colors.transparent;
                                  tagger = "";
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                      child: Text("Waitng for more players to join.."),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
