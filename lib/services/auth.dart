import 'package:firebase_auth/firebase_auth.dart';
import 'package:light0/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // set user in db

  //auth change stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // get user object from firebaseAuth user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      String errorMsg = e.toString();
      print("error signing in $errorMsg");
      return null;
    }
  }

  Future logout() async {
    return await _auth.signOut();
  }
}
