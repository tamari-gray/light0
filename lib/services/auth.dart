import 'package:firebase_auth/firebase_auth.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/Db/game/init_game.dart';
import 'package:light0/services/Db/user/user-info.dart';

abstract class Auth {
  FirebaseAuth auth;
  Stream<User> get user;
  User userFromFirebaseUser(FirebaseUser user);
  Future signInAnon(String username);
  Future logout(UserData user);
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
      await UserInfoService(userId: user.uid).updateUserData(username);

      if (username == "tam_is_cool")
        await UserInfoService(userId: user.uid).makeAdmin();

      return userFromFirebaseUser(user);
    } catch (e) {
      String errorMsg = e.toString();
      print("error signing in $errorMsg");
      return null;
    }
  }

  @override
  Future logout(UserData user) async {
    print("logging out user:  ${user.isAdmin}, ${user.userId}");
    await auth.signOut();
    if (user.isAdmin) {
      await UserInfoService(userId: user.userId).deleteAccount();
      return await InitGameService().deleteGame();
    } else if (!user.isAdmin) {
      return await UserInfoService(userId: user.userId).deleteAccount();
    }
  }
}
