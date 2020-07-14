import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';

abstract class PlayersInfo {
  List<UserData> playerDataFromSnapshot(QuerySnapshot snapshot);

  Stream<List<UserData>> get playerData;

  DocumentReference gameRef;
}

class PlayersInfoService extends PlayersInfo {
  @override
  DocumentReference gameRef = GameService().gameRef;

  @override
  List<UserData> playerDataFromSnapshot(QuerySnapshot snapshot) {
    print("getting ${snapshot.documents.length} players");

    return snapshot.documents.map((doc) {
      print(doc.data["username"]);
      return UserData(
          username: doc.data["username"].toString() ?? "",
          userId: doc.documentID);
    }).toList();
  }

  @override
  Stream<List<UserData>> get playerData {
    return gameRef.collection("users").snapshots().map(playerDataFromSnapshot);
  }
}
