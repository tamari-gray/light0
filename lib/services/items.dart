import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/item.dart';
import 'package:light0/services/db.dart';

GeoPoint _newItemPosition(LatLng boundaryCentre, double radius) {
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

class ItemsService {
  void generateNewItems(
      LatLng boundaryCentre, double radius, double amountOfItems) async {
    List<Item> _newItems;

    // make new item for items in itemcount
    for (var i = 0; i < amountOfItems; i++) {
      while (_newItems.length < amountOfItems) {
        GeoPoint _position = _newItemPosition(boundaryCentre, radius);

        // geoquery check
        // Future<bool> hi = GeoqueryService.checkIfSufficientlySpaced(
        //     _position, _boundaryRadius.toInt());
        bool _itemSufficientlySpaced = true;

        if (_itemSufficientlySpaced) {
          _newItems.add(
            Item(
              isPickedUp: false,
              position: _position,
            ),
          );
        }
      }

      if (_newItems.length == amountOfItems) {
        await DbService().setItems(_newItems);
        // return _newItems;
      }
    }
  }

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
}
