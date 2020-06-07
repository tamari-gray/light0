import 'package:cloud_firestore/cloud_firestore.dart';

class GameData {
  final GeoPoint boundaryPosition;
  final double boundaryRadius;
  final String gameState;
  final double remainingPlayers;

  GameData(
      {this.boundaryPosition,
      this.boundaryRadius,
      this.gameState,
      this.remainingPlayers});
}
