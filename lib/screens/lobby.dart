import 'package:flutter/material.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:provider/provider.dart';

class Lobby extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _userData = Provider.of<UserData>(context);
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _userData != null ? Text(_userData.username) : Container(),
            RaisedButton(
              child: Text("sign out"),
              onPressed: () async {
                await _auth.logout(_user.userId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
