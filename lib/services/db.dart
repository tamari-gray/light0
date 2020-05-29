import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/user.dart';
import 'package:light0/models/userData.dart';

class DbService {
  final String userId;
  DbService({this.userId});

  final CollectionReference usersColl = Firestore.instance.collection('users');

  Future updateUserData(String username) async {
    return await usersColl.document(userId).setData({"username": username});
  }

  deleteAccount() async {
    return await usersColl.document(userId).delete();
  }

  Future<UserData> get userData async {
    return await usersColl.document(userId).get().then((doc) {
      print(doc.data["username"]);
      return doc.exists
          ? UserData(username: doc.data["username"].toString())
          : "null";
    });
  }
}
