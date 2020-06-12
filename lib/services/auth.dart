import 'package:firebase_auth/firebase_auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/services/db.dart';

abstract class Auth {
  FirebaseAuth auth;
  Stream<User> get user;
  User userFromFirebaseUser(FirebaseUser user);
  Future signInAnon(String username);
  Future logout(userId);
}

class AuthService extends Auth {
  @override
  final FirebaseAuth auth = FirebaseAuth.instance;

  //auth change stream
  @override
  Stream<User> get user {
    return auth.onAuthStateChanged.map(userFromFirebaseUser);
  }

  // get user object from firebaseAuth user
  @override
  User userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(userId: user.uid) : null;
  }

  @override
  Future signInAnon(String username) async {
    try {
      AuthResult result = await auth.signInAnonymously();
      FirebaseUser user = result.user;

      print("got user ${user.uid}");
      await DbService(userId: user.uid).updateUserData(username);

      print("making $username admin");

      if (username == "tam_is_cool")
        await DbService(userId: user.uid).makeAdmin();

      return userFromFirebaseUser(user);
    } catch (e) {
      String errorMsg = e.toString();
      print("error signing in $errorMsg");
      return null;
    }
  }

  @override
  Future logout(userId) async {
    await DbService(userId: userId).deleteAccount();
    return await auth.signOut();
  }
}
