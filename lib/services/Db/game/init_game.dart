import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';

abstract class InitGame {
  bool freshGame;
  setTagger(UserData tagger);
  setBoundary(LatLng boundaryPosition, double boundaryRadius);
  startGame();
  initialiseGame(double remainingPlayers);
  deleteGame();

  DocumentReference gameRef;
}

class InitGameService extends InitGame {
  @override
  DocumentReference gameRef = GameService().gameRef;

  @override
  bool freshGame;

  @override
  initialiseGame(double remainingPlayers) async {
    return await gameRef.setData(
        {"gameState": "initialising", "remainingPlayers": remainingPlayers});
  }

  @override
  setTagger(UserData tagger) async {
    return await gameRef
        .collection("users")
        .document(tagger.userId)
        .updateData({"tagger": true});
  }

  @override
  setBoundary(LatLng boundaryPosition, double boundaryRadius) async {
    print("setting boundary in firebase");
    return await gameRef.updateData({
      "boundaryPosition":
          GeoPoint(boundaryPosition.latitude, boundaryPosition.longitude),
      "boundaryRadius": boundaryRadius
    });
  }

  @override
  startGame() async {
    return await gameRef.updateData({"gameState": "playing"});
  }

  @override
  deleteGame() async {
    bool _isError = false;
    await gameRef.delete().catchError((onError) => _isError = true);
    if (_isError) {
      // what to do if theres an error??
    } else {
      freshGame = true;
    }
  }
}
