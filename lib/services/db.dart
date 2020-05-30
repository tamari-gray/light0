import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';

class DbService {
  final String userId;
  DbService({this.userId});

  final DocumentReference gameRef =
      Firestore.instance.collection("games").document("game1");

  Future updateUserData(String username) async {
    return await gameRef
        .collection("users")
        .document(userId)
        .setData({"username": username});
  }

  deleteAccount() async {
    return await gameRef.collection("users").document(userId).delete();
  }

  Future<UserData> get userData async {
    return await gameRef.collection("users").document(userId).get().then((doc) {
      print(doc.data["admin"]);
      return doc.exists
          ? UserData(
              username: doc.data["username"].toString(),
              isAdmin: doc.data["admin"],
            )
          : "null";
    });
  }

  makeAdmin() async {
    // print("des es de admin");
    return await gameRef
        .collection("users")
        .document(userId)
        .updateData({"admin": true});
  }
}
