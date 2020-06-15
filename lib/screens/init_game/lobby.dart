import 'package:flutter/material.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/screens/init_game/gameSettings.dart';
import 'package:light0/shared/loading.dart';
import 'package:provider/provider.dart';

class Lobby extends StatefulWidget {
  final InitGame initGameService;
  Lobby({this.initGameService});
  @override
  _LobbyState createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final AuthService _auth = AuthService();
  Color color;
  UserData tagger;
  bool _waitingForSetTaggerResponse;

  @override
  void initState() {
    super.initState();
    color = Colors.transparent;
    tagger = UserData(username: "tagger", userId: "taggerId");
    _waitingForSetTaggerResponse = false;
  }

  _setTagger() async {
    dynamic setTaggerResult = await widget.initGameService.setTagger(tagger);
    setState(() {
      _waitingForSetTaggerResponse = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameSettings(
          initGameService: InitGameService(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _userData = Provider.of<UserData>(context) != null
        ? Provider.of<UserData>(context)
        : UserData(username: "", userId: "");
    final _players = Provider.of<List<UserData>>(context) != null
        ? Provider.of<List<UserData>>(context)
        : List.from([
            UserData(username: "ye", userId: ""),
            UserData(username: "yee", userId: "")
          ]);
    final _snackBar = SnackBar(
      content: Text('choose a tagger'),
    );

    if (_waitingForSetTaggerResponse) _setTagger();

    if (_players != null && _userData != null)
      return Scaffold(
        appBar: AppBar(
          title: Text("Welcome"),
          actions: <Widget>[
            FlatButton.icon(
              key: Key("logout_button"),
              label: Text("leave game"),
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await _auth.logout(_userData);
              },
            ),
          ],
        ),
        body: _waitingForSetTaggerResponse
            ? Loading()
            : Builder(
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
                                key: tagger == _players[index]
                                    ? Key("tagger_tile")
                                    : null,
                                title: tagger == _players[index]
                                    ? Text(
                                        "${_players[index].username} is the tagger")
                                    : Text(
                                        "${_players[index].username} has joined"),
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
                                            username: "tagger",
                                            userId: "taggerId");
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
                                key: Key("go_to_game_settings"),
                                onPressed: () async {
                                  if (tagger.userId == "taggerId") {
                                    Scaffold.of(context)
                                        .showSnackBar(_snackBar);
                                  } else {
                                    if (_waitingForSetTaggerResponse == false) {
                                      setState(() {
                                        _waitingForSetTaggerResponse = true;
                                      });
                                    }
                                  }
                                },
                                child: Text("Set boundary"),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 50, 0, 100),
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
