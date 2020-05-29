import 'package:flutter/material.dart';
import 'package:light0/screens/signUp.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider(
      create: (_) => AuthService().user,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Wrapper(),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    return _user == null
        ? LoginAnon()
        : Scaffold(
            body: Container(
              child: Center(
                child: RaisedButton(
                  child: Text("sign out"),
                  onPressed: () async {
                    await _auth.logout();
                  },
                ),
              ),
            ),
          );
  }
}
