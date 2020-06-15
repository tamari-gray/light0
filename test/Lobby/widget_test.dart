import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/screens/auth/signUp.dart';
import 'package:light0/screens/init_game/lobby.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class InitGameMock extends InitGame {
  @override
  bool freshGame;
  @override
  setTagger(UserData tagger) {}
  @override
  setBoundary(LatLng boundaryPosition, double boundaryRadius) {}
  @override
  startGame() {}
  @override
  initialiseGame(double remainingPlayers) {}
  @override
  deleteGame() {}
}

void main() {
  UserData _user;
  StreamController<List<UserData>> _controller;

  setUp(() {
    _controller = StreamController<List<UserData>>.broadcast();
    _user = UserData(userId: "0");
  });

  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('choose tagger', () {
    testWidgets('set tagger in db and show loading icon',
        (WidgetTester tester) async {
      // set up widget
      await tester.pumpWidget(makeTestableWidget(
        child: MultiProvider(
          providers: [
            StreamProvider<UserData>(
              create: (_) => Stream.fromIterable([
                UserData(
                    userId: "tams_is_cool_id",
                    username: "tam_is_cool",
                    isAdmin: true)
              ]),
            ),
            StreamProvider<List<UserData>>(
              create: (_) => _controller.stream,
            ),
          ],
          child: Lobby(initGameService: InitGameMock()),
        ),
      ));

      // set up data
      List gotUsers = <UserData>[];
      gotUsers.add(
        UserData(username: "otherPlayer", userId: "mockPlayer"),
      );
      gotUsers.add(UserData(
          userId: "tams_is_cool_id", username: "tam_is_cool", isAdmin: true));

      _controller.add(gotUsers);
      await tester.pump();

      // tap first player in list
      await tester.tap(find.byType(ListTile).at(0));
      await tester.pump();

      // tap set boundary btn
      var setBoundaryBtn = find.byKey(Key("go_to_game_settings"));
      expect(setBoundaryBtn, findsNWidgets(1));
      await tester.tap(setBoundaryBtn);
      await tester.pump();

      // check if can find loading indicator
      var loadingWidget = find.byKey(Key("loading_indicator"));
      expect(loadingWidget, findsNWidgets(1));
    });
  });
}
