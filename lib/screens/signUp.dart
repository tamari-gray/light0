import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/auth.dart';

class LoginAnon extends StatefulWidget {
  @override
  _LoginAnonState createState() => _LoginAnonState();
}

class _LoginAnonState extends State<LoginAnon> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  String userName = '';
  @override
  Widget build(BuildContext context) {
    final _usernames = Provider.of<List<UserData>>(context) != null
        ? Provider.of<List<UserData>>(context).map((e) => e.username).toList()
        : [];
    return Scaffold(
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("LIGHT0 boi"),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: Center(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Enter username'),
                    onChanged: (val) {
                      setState(() {
                        userName = val;
                      });
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter username';
                      } else if (_usernames != null &&
                          _usernames.contains(value)) {
                        return 'username has been taken, please choose another one';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    dynamic result = await _auth.signInAnon(userName);
                    // print("signed in $result");
                  }
                },
                child: Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
