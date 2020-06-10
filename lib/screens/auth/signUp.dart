import 'package:flutter/material.dart';
import 'package:light0/models/user.dart';
import 'package:provider/provider.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/shared/loading.dart';

class LoginAnon extends StatefulWidget {
  @override
  _LoginAnonState createState() => _LoginAnonState();
}

class _LoginAnonState extends State<LoginAnon> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  String userName = '';
  bool _awaitingAuthResult;
  bool _errorSigningUp;

  @override
  void initState() {
    super.initState();
    _awaitingAuthResult = false;
    _errorSigningUp = false;
  }

  @override
  Widget build(BuildContext context) {
    final _usernames = Provider.of<List<UserData>>(context) != null
        ? Provider.of<List<UserData>>(context).map((e) => e.username).toList()
        : [];
    return Scaffold(
      body: Container(
        child: _awaitingAuthResult
            ? Loading()
            : Form(
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
                          decoration:
                              InputDecoration(labelText: 'Enter username'),
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
                      key: Key("sign_up_button"),
                      onPressed: () async {
                        if (_formKey.currentState.validate() &&
                            !_awaitingAuthResult) {
                          setState(() {
                            _awaitingAuthResult = true;
                          });
                          dynamic result = await _auth.signInAnon(userName);
                          if (result == null) {
                            setState(() {
                              _awaitingAuthResult = false;
                              _errorSigningUp = true;
                            });
                          }
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
