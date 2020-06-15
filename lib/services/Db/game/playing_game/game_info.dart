import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/gameData.dart';

abstract class GameInfo {
  Stream<GameData> get gameData;

  Future<LatLng> get getBoundaryPosition;
}

class GameService extends GameInfo {
  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");

  @override
  Stream<GameData> get gameData {
    return gameRef.snapshots().map((DocumentSnapshot snap) {
      return GameData(
        boundaryPosition: snap.data["boundaryPosition"],
        boundaryRadius: snap.data["boundaryRadius"],
        gameState: snap.data["gameState"].toString(),
        remainingPlayers: snap.data["remainingPlayers"],
      );
    });
  }

  @override
  Future<LatLng> get getBoundaryPosition {
    return gameRef.get().then((doc) {
      if (doc.exists) {
        print("doc exists");
      }
      final GeoPoint boundary = doc.data["boundaryPosition"];

      print(doc.data);

      print("got boundary from db: $boundary");
      return LatLng(boundary.latitude, boundary.longitude);
    });
  }
}
