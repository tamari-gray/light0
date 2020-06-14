import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/models/userLocation.dart';

abstract class Db {
  final String userId;
  Db({this.userId});
  Future updateUserData(String username);
  deleteAccount();
  UserData userDataFromSnapshot(DocumentSnapshot snapshot);
  Stream<UserData> get userData;
  List<UserData> playerDataFromSnapshot(QuerySnapshot snapshot);

  Stream<List<UserData>> get playerData;

  makeAdmin();

  initialiseGame(double remainingPlayers);

  setTagger(UserData tagger);

  setBoundary(LatLng boundaryPosition, double boundaryRadius);

  Future<LatLng> get getBoundaryPosition;

  startGame();
  Stream<GameData> get gameData;

  Future<bool> checkForItem(UserLocation location);

  List<Item> itemFromSnapshot(QuerySnapshot snapshot);

  Stream<List<Item>> get getItems;

  // add items to db coll
  setItems(List<Item> items);
}

class DbService extends Db {
  final String userId;
  DbService({this.userId});

  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");

  @override
  Future updateUserData(String username) async {
    return await gameRef
        .collection("users")
        .document(userId)
        .setData({"username": username});
  }

  @override
  deleteAccount() async {
    return await gameRef.collection("users").document(userId).delete();
  }

  @override
  UserData userDataFromSnapshot(DocumentSnapshot snapshot) {
    print(
        "got user data: ${snapshot.data['username']}, isAdmin = ${snapshot.data['admin']}");
    return UserData(
      username: snapshot.data['name'],
      isAdmin: snapshot.data["admin"],
      isTagger: snapshot.data["tagger"],
    );
  }

  @override
  Stream<UserData> get userData {
    return gameRef
        .collection("users")
        .document(userId)
        .snapshots()
        .map(userDataFromSnapshot);
  }

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

  @override
  makeAdmin() async {
    // print("des es de admin");
    return await gameRef
        .collection("users")
        .document(userId)
        .updateData({"admin": true});
  }

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

  @override
  startGame() async {
    return await gameRef.updateData({"gameState": "playing"});
  }

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
  Future<bool> checkForItem(UserLocation location) async {
    // do geoquery
    print("checking for item at: ${location.latitude}");

    // update db
    return await false;
  }

  @override
  List<Item> itemFromSnapshot(QuerySnapshot snapshot) {
    print("getting ${snapshot.documents.length} items");

    return snapshot.documents.map((doc) {
      // print(doc.data["username"]);
      return Item(
          isPickedUp: doc.data["isPickedUp"] ?? true,
          position: doc.data["position"],
          id: doc.data["id"]);
    }).toList();
  }

  @override
  Stream<List<Item>> get getItems {
    return gameRef
        .collection("items")
        .where("isPickedUp", isEqualTo: false)
        .snapshots()
        .map(itemFromSnapshot);
  }

  @override
  setItems(List<Item> items) async {
    items.forEach((item) async {
      await gameRef.collection("items").document(item.id).setData({
        "isPickedUp": item.isPickedUp,
        "position": item.position,
        "id": item.id
      });
    });
  }
}
