import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final GeoPoint position;
  final bool isPickedUp;

  Item({this.position, this.isPickedUp});
}
