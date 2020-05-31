import 'package:flutter/material.dart';

class PlayingGame extends StatelessWidget {
  const PlayingGame({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text("game screen"),
          leading: IconButton(
            icon: Icon(Icons.ac_unit),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
