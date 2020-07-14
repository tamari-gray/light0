import 'package:flutter/material.dart';
import 'package:light0/screens/auth/signUp.dart';
import 'package:light0/screens/init_game/lobby.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';
import 'package:light0/services/Db/game/playing_game/players.dart';
import 'package:light0/services/Db/user/user-info.dart';
import 'package:light0/services/auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
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
        // StreamProvider<UserLocation>(
        //   create: (_) => LocationService().locationStream,
        // ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    if (_user == null) {
      return StreamProvider<List<UserData>>(
        create: (_) => PlayersInfoService().playerData,
        child: LoginAnon(
          auth: AuthService(),
        ),
      );
    } else {
      return MultiProvider(
        providers: [
          StreamProvider<UserData>(
            create: (_) => UserInfoService(userId: _user.userId).userData,
          ),
          StreamProvider<List<UserData>>(
            create: (_) => PlayersInfoService().playerData,
          ),
        ],
        child: Lobby(
          initGameService: InitGameService(),
        ),
      );
    }
  }
}
