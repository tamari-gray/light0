import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/user.dart';

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
}
