import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/screens/init_game/lobby.dart';
import 'package:light0/services/db.dart';
import 'package:provider/provider.dart';

class DbMock extends Db {
  final String userId;
  DbMock({this.userId});

  @override
  Future updateUserData(String username) async {
    return await null;
  }

  @override
  deleteAccount() async {}

  @override
  UserData userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData();
  }

  @override
  Stream<UserData> get userData {}

  @override
  List<UserData> playerDataFromSnapshot(QuerySnapshot snapshot) {}

  @override
  Stream<List<UserData>> get playerData {}

  @override
  makeAdmin() async {}

  @override
  initialiseGame(double remainingPlayers) async {}

  @override
  setTagger(UserData tagger) async {
    return "success";
  }

  @override
  setBoundary(LatLng boundaryPosition, double boundaryRadius) async {}

  @override
  Future<LatLng> get getBoundaryPosition {}

  @override
  startGame() async {}

  @override
  Stream<GameData> get gameData {}

  @override
  Future<bool> checkForItem(UserLocation location) async {}

  @override
  List<Item> itemFromSnapshot(QuerySnapshot snapshot) {}

  @override
  Stream<List<Item>> get getItems {}

  @override
  setItems(List<Item> items) async {}
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
          child: Lobby(dbService: DbMock(userId: "tam")),
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
