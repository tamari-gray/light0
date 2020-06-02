import 'package:flutter/material.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/screens/signUp.dart';
import 'package:light0/screens/lobby.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/services/db.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/location.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>(
          create: (_) => AuthService().user,
        ),
        StreamProvider<UserLocation>(
          create: (_) => LocationService().locationStream,
        ),
      ],
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
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    if (_user == null) {
      return StreamProvider<List<UserData>>(
        create: (_) => DbService().playerData,
        child: LoginAnon(),
      );
    } else {
      return MultiProvider(
        providers: [
          StreamProvider<UserData>(
            create: (_) => DbService(userId: _user.userId).userData,
          ),
          StreamProvider<List<UserData>>(
            create: (_) => DbService().playerData,
          ),
        ],
        child: Lobby(),
      );
    }
  }
}
