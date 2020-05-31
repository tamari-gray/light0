import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';

class DbService {
  final String userId;
  DbService({this.userId});

  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");

  Future updateUserData(String username) async {
    return await gameRef
        .collection("users")
        .document(userId)
        .setData({"username": username});
  }

  deleteAccount() async {
    return await gameRef.collection("users").document(userId).delete();
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    print(
        "got user data: ${snapshot.data['username']}, isAdmin = ${snapshot.data['admin']}");
    return UserData(
        username: snapshot.data['name'], isAdmin: snapshot.data["admin"]);
  }

  Stream<UserData> get userData {
    return gameRef
        .collection("users")
        .document(userId)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  List<UserData> _playerDataFromSnapshot(QuerySnapshot snapshot) {
    print("getting ${snapshot.documents.length} players");

    return snapshot.documents.map((doc) {
      print(doc.data["username"]);
      return UserData(
          username: doc.data["username"].toString() ?? "",
          userId: doc.documentID);
    }).toList();
  }

  Stream<List<UserData>> get playerData {
    return gameRef.collection("users").snapshots().map(_playerDataFromSnapshot);
  }

  makeAdmin() async {
    // print("des es de admin");
    return await gameRef
        .collection("users")
        .document(userId)
        .updateData({"admin": true});
  }

  initialiseGame() async {
    return await gameRef.setData({"gameState": "initialising"});
  }

  setTagger(UserData tagger) async {
    return await gameRef
        .collection("users")
        .document(tagger.userId)
        .updateData({"tagger": true});
  }
}
