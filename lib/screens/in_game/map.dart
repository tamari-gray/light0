import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:light0/models/item.dart';
import 'package:light0/models/userLocation.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';
import 'package:light0/services/Db/game/playing_game/items.dart';
import 'package:light0/services/location.dart';
import 'package:light0/shared/loading.dart';
import 'package:provider/provider.dart';

class InGameMap extends StatefulWidget {
  final bool tagger;
  final GameInfo gameInfo;
  final Items itemsService;
  InGameMap(
      {@required this.tagger,
      @required this.gameInfo,
      @required this.itemsService});

  @override
  _InGameMapState createState() => _InGameMapState();
}

class _InGameMapState extends State<InGameMap> {
  GoogleMapController _mapController;
  Set<Marker> _itemMarkers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();

  UserLocation _myLocation;
  LatLng _boundaryCentre;

  double _boundaryRadius;

  @override
  void initState() {
    _boundaryRadius = 50;
    _myLocation = null;
    _getLocation();
    _updateBoundaryPosition();
    super.initState();
  }

  _getLocation() async {
    UserLocation userLocation = await LocationService().getLocation();
    setState(() {
      _myLocation = userLocation;
    });
  }

  void _updateBoundaryPosition() async {
    await widget.gameInfo.getBoundaryPosition.then((LatLng position) {
      print("got boundary position: ${position.latitude}");
      _circles.add(
        Circle(
          circleId: CircleId("boundary"),
          center: position,
          radius: _boundaryRadius,
          strokeWidth: 3,
          strokeColor: Color.fromRGBO(102, 51, 153, 1),
          fillColor: Color.fromRGBO(102, 51, 153, 0.3),
          zIndex: 1,
        ),
      );

      setState(() {
        _boundaryCentre = position;
      });

      // if (widget.tagger) _setItems();
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_myLocation.latitude, _myLocation.longitude), 17));
    // _setMapStyle();
  }

  // void _setMapStyle() async {
  // String style = await DefaultAssetBundle.of(context)
  //     .loadString("assets/map_style.json");
  // _mapController.setMapStyle(style);
  // }

  void _putItemsOnMap(items) {
    print("what are items? : $items");
    final _newItemMarkers = widget.itemsService.markersFromItems(items);
    print("putting items on map: ${_newItemMarkers.length}");
    setState(() {
      _itemMarkers.removeWhere((e) => e is Marker);
    });

    print("removed previous markers: ${_itemMarkers.length}");

    setState(() {
      _itemMarkers = _newItemMarkers;
    });
    print("and added new ones: ${_itemMarkers.length}");
  }

  @override
  Widget build(BuildContext context) {
    final _itemsList = Provider.of<List<Item>>(context);

    if (_itemsList != null && _itemsList.length > 0) _putItemsOnMap(_itemsList);

    if (_myLocation == null) {
      return Loading();
    } else {
      return Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(_myLocation.latitude, _myLocation.longitude),
              zoom: 17,
            ),
            circles: _circles,
            markers: _itemMarkers,
            myLocationEnabled: true,
          ),
        ],
      );
    }
  }
}
