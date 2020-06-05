import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoqueryService {
  Firestore _firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  // get the collection reference or query
  final CollectionReference collectionReference =
      Firestore.instance.collection('locations');

  checkIfSufficientlySpaced(LatLng centerPoint, int radius) async {
    //do geoquery stuff
    GeoFirePoint center = geo.point(
        latitude: centerPoint.latitude, longitude: centerPoint.longitude);

    double radius = 0.015;
    String field = 'position';

    Stream<List<DocumentSnapshot>> geoquery = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
    // .map((itemList) => itemList.isEmpty ? true : false);

    print("geoquery isEmpty: ${geoquery.isEmpty}");

    //add to db if true

    // if (geoquery.isEmpty) {}

    GeoFirePoint myLocation = geo.point(
        latitude: centerPoint.latitude, longitude: centerPoint.longitude);

    await _firestore
        .collection('games')
        .document('game1')
        .collection('items')
        .add({'position': myLocation.data});
  }
}
