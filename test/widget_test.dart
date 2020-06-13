import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/screens/auth/signUp.dart';
import 'package:light0/services/auth.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuth extends Auth {
  @override
  Stream<User> get user {
    return Stream.fromIterable([User()]);
  }

  @override
  User userFromFirebaseUser(FirebaseUser user) {
    return User();
  }

  @override
  Future signInAnon(String username) async {
    return await "yeet";
  }

  @override
  Future logout(userId) async {
    return await null;
  }
}

class FirebaseError extends Auth {
  @override
  Stream<User> get user {
    return Stream.fromIterable([User()]);
  }

  @override
  User userFromFirebaseUser(FirebaseUser user) {
    return User();
  }

  @override
  Future signInAnon(String username) async {
    return await null;
  }

  @override
  Future logout(userId) async {
    return await null;
  }
}

class MockitoAuth extends Mock implements Auth {}

void main() {
  UserData _user;
  StreamController<List<UserData>> _controller;
  var auth = MockitoAuth();

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
            child: LoginAnon(
              auth: MockAuth(),
            ),
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
      expect(loadingIndicator, findsNWidgets(1));
    });

    testWidgets('show error if firebase auth returns error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: StreamProvider<List<UserData>>(
            create: (_) => _controller.stream,
            child: LoginAnon(
              auth: FirebaseError(),
            ),
          ),
        ),
      );

      var button = find.byKey(
        Key("sign_up_button"),
      );
      var textFeild = find.byType(TextFormField);
      expect(button, findsNWidgets(1));
      expect(textFeild, findsNWidgets(1));

      await tester.enterText(textFeild, "gimme an error firebase");
      await tester.tap(button);
      await tester.pump();

      var signUpError = find.byKey(
        Key("sign_up_error_notification"),
      );
      expect(signUpError, findsNWidgets(1));
    });
  });
}
