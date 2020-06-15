import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/gameData.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userLocation.dart';

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
  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");

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
    List<Item> _newItems;
    double amountOfItems = gameData.remainingPlayers / 2;

    // make new item for items in itemcount
    for (var i = 0; i < amountOfItems; i++) {
      while (_newItems.length < amountOfItems) {
        GeoPoint _position =
            newItemPosition(gameData.boundaryPosition, gameData.boundaryRadius);

        // geoquery check
        // Future<bool> hi = GeoqueryService.checkIfSufficientlySpaced(
        //     _position, _boundaryRadius.toInt());
        bool _itemSufficientlySpaced = true;

        if (_itemSufficientlySpaced) {
          _newItems.add(
            Item(
                isPickedUp: false,
                position: _position,
                id: "${_position.latitude}_${_position.latitude}"),
          );
        }
      }

      if (_newItems.length == amountOfItems) {
        print("generated new items: ${_newItems.length}");
        await setItems(_newItems);
        return;
        // return _newItems;
      }
    }
  }

  @override
  Set<Marker> markersFromItems(List<Item> items) {
    Set<Marker> _newItems = HashSet<Marker>();

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
