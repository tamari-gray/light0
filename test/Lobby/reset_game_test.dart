// Import the test package and Counter class
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:test/test.dart';

class InitGameMock extends InitGame {
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
  WidgetsFlutterBinding.ensureInitialized();
  test('check if admin then delete games coll', () {
    final initGame = InitGameService();

    InitGameService().deleteGame();

    expect(initGame.freshGame, true);
  });
}
