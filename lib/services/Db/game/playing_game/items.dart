import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';

abstract class Items {
  void generateNewItems(GameData gameData);
  Set<Marker> markersFromItems(List<Item> items);
  GeoPoint newItemPosition(GeoPoint boundaryCentre, double radius);

  Future<bool> checkForItem(UserLocation location);
  List<Item> itemFromSnapshot(QuerySnapshot snapshot);
  Stream<List<Item>> get getItems;
  // add items to db coll
  setItems(List<Item> items);
}

class ItemsService extends Items {
  final DocumentReference gameRef = GameService().gameRef;

  @override
  GeoPoint newItemPosition(GeoPoint boundaryCentre, double radius) {
    double y0 = boundaryCentre.latitude;
    double x0 = boundaryCentre.longitude;
    Random randomPoint = new Random();

    // radius to degrees
    double radiusInDegrees = radius / 111000;

    // calcliations
    double u = randomPoint.nextDouble();
    double v = randomPoint.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t);

    double newX = x / cos(y0);
    double foundLongitude = newX + x0;
    double foundLatitude = y + y0;

    print("new item coords: $foundLatitude, $foundLongitude");

    return GeoPoint(foundLatitude, foundLongitude);
  }

  @override
  void generateNewItems(GameData gameData) async {
    List<Item> _newItems = <Item>[];
    // double amountOfItems = gameData.remainingPlayers / 2;
    int amountOfItems = 5;
    print("amount of items: $amountOfItems");

    // make new item for items in itemcount
    for (var i = 0; i < amountOfItems; i++) {
      GeoPoint _position =
          newItemPosition(gameData.boundaryPosition, gameData.boundaryRadius);
      _newItems.add(
        Item(
            isPickedUp: false,
            position: _position,
            id: "${_position.latitude}_${_position.latitude}"),
      );
    }

    print("generated new items: ${_newItems.length}");
    return await setItems(_newItems);
  }

  @override
  Set<Marker> markersFromItems(List<Item> items) {
    Set<Marker> _newItems = HashSet<Marker>();

    print(
        "creating markers from items: ${items.length} ${items.first.position.latitude}");

    items.forEach((item) {
      _newItems.add(
        Marker(
          markerId: MarkerId("${item.position.latitude}"),
          position: LatLng(item.position.latitude, item.position.longitude),
        ),
      );
    });

    return _newItems;
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
    print("getting ${snapshot.documents.length} items from db");

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
    await gameRef.collection("items").getDocuments().then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });

    print("setting ${items.length} items in db");
    items.forEach((item) async {
      await gameRef.collection("items").document(item.id).setData({
        "isPickedUp": item.isPickedUp,
        "position": item.position,
        "id": item.id
      });
    });
  }
}
