import 'package:flutter/material.dart';
import 'package:light0/services/auth.dart';

class LoginAnon extends StatefulWidget {
  @override
  _LoginAnonState createState() => _LoginAnonState();
}

class _LoginAnonState extends State<LoginAnon> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
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
                    // The validator receives the text that the user has entered.

                    // validation : check if username has been taken?? ////////////////////////////////////

                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    // SAVE TO FIREBASE

                    dynamic result = await _auth.signInAnon();

                    print("signed in ${result.uid}");

                    // Scaffold.of(context).showSnackBar(r
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
