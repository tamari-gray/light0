import 'package:flutter/material.dart';
import 'package:light0/services/db.dart';
import 'package:light0/screens/playingGame.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:provider/provider.dart';

class SetBoundary extends StatefulWidget {
  @override
  _SetBoundaryState createState() => _SetBoundaryState();
}

class _SetBoundaryState extends State<SetBoundary> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    // final _userData = Provider.of<UserData>(context) != null
    //     ? Provider.of<UserData>(context)
    //     : UserData(username: "", userId: "");
    return Scaffold(
      appBar: AppBar(
        title: Text("Hold and drag to reposition"),
        actions: <Widget>[],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                child: Text("map"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
              child: RaisedButton(
                onPressed: () {
                  _showMyDialog(_user.userId);
                },
                child: Text("start game"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap back
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you ready?'),
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
