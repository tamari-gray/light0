import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/userLocation.dart';

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
      username: snapshot.data['name'],
      isAdmin: snapshot.data["admin"],
      isTagger: snapshot.data["tagger"],
    );
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

  setBoundary(LatLng boundaryPosition, double boundaryRadius) async {
    print("setting boundary in firebase");
    return await gameRef.updateData({
      "boundaryPosition":
          GeoPoint(boundaryPosition.latitude, boundaryPosition.longitude),
      "boundaryRadius": boundaryRadius
    });
  }

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

  startGame() async {
    return await gameRef.updateData({"gameState": "playing"});
  }

  Stream<GameData> get gameData {
    return gameRef.snapshots().map((DocumentSnapshot snap) {
      return GameData(
        boundaryPosition: LatLng(snap.data["boundaryPosition"].latitude,
            snap.data["boundaryPosition"].longitude),
        boundaryRadius: snap.data["boundaryRadius"],
        gameState: snap.data["gameState"].toString(),
      );
    });
  }

  Future<bool> checkForItem(UserLocation location) async {
    // do geoquery
    print("checking for item at: ${location.latitude}");

    // update db
    return await false;
  }

  List<Item> _itemFromSnapshot(QuerySnapshot snapshot) {
    print("getting ${snapshot.documents.length} items");

    return snapshot.documents.map((doc) {
      // print(doc.data["username"]);
      return Item(
        isPickedUp: doc.data["isPickedUp"] ?? true,
        position: GeoPoint(0, 0),
      );
    }).toList();
  }

  Stream<List<Item>> get getItems {
    return gameRef.collection("items").snapshots().map(_itemFromSnapshot);
  }

  // add items to db coll
  setItems(List<Item> items) async {
    // await
  }
}
