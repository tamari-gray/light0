// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/screens/auth/signUp.dart';
import 'package:provider/provider.dart';

void main() {
  UserData _user;

  StreamController<List<UserData>> _controller;

  setUp(() {
    _controller = StreamController<List<UserData>>();
    _user = UserData(userId: "0");
  });

  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('create account in firebase', () {
    testWidgets('show loading indicator when waiting for firebase auth result',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        makeTestableWidget(
          child: StreamProvider<List<UserData>>(
            create: (_) => _controller.stream,
            child: LoginAnon(),
          ),
        ),
      );

      var button = find.byKey(Key("sign_up_button"));
      var textFeild = find.byType(TextFormField);
      expect(button, findsNWidgets(1));
      expect(textFeild, findsNWidgets(1));

      await tester.enterText(textFeild, "yeet");
      await tester.tap(button);
      await tester.pump();

      var loadingIndicator = find.byKey(Key("loading_indicator"));
      expect(loadingIndicator, findsNWidgets(0));
    });

    testWidgets('show error if firebase auth returns error',
        (WidgetTester tester) async {});

    testWidgets('reset state if firebase auth returns error',
        (WidgetTester tester) async {});

    testWidgets('redirect to lobby page on firebase auth success',
        (WidgetTester tester) async {});
  });
}
