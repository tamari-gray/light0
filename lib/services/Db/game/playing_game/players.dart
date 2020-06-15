import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/userData.dart';

abstract class PlayersInfo {
  List<UserData> playerDataFromSnapshot(QuerySnapshot snapshot);

  Stream<List<UserData>> get playerData;
}

class PlayersInfoService extends PlayersInfo {
  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");
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
