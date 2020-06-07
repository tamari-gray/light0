import 'package:google_maps_flutter/google_maps_flutter.dart';

class GameData {
  final LatLng boundaryPosition;
  final double boundaryRadius;
  final String gameState;

  GameData({this.boundaryPosition, this.boundaryRadius, this.gameState});
}
