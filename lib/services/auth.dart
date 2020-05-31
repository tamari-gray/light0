import 'package:firebase_auth/firebase_auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/services/db.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // set user in db

  //auth change stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // get user object from firebaseAuth user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(userId: user.uid) : null;
  }

  Future signInAnon(String username) async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;

      print("got user ${user.uid}");
      await DbService(userId: user.uid).updateUserData(username);

      print("making $username admin");

      username == "tam_is_cool"
          ? await DbService(userId: user.uid).makeAdmin()
          : null;

      return _userFromFirebaseUser(user);
    } catch (e) {
      String errorMsg = e.toString();
      print("error signing in $errorMsg");
      return null;
    }
  }

  Future logout(userId) async {
    await DbService(userId: userId).deleteAccount();
    return await _auth.signOut();
  }
}
