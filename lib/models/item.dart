import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final GeoPoint position;
  final bool isPickedUp;
  final String id;

  Item({this.position, this.isPickedUp, this.id});
}
