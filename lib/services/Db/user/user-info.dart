import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:light0/models/userData.dart';
import 'package:light0/services/Db/game/playing_game/game_info.dart';

abstract class UserInfo {
  final String userId;
  UserInfo({this.userId});
  Future updateUserData(String username);
  deleteAccount();
  UserData userDataFromSnapshot(DocumentSnapshot snapshot);
  Stream<UserData> get userData;
  makeAdmin();

  DocumentReference gameRef;
}

class UserInfoService extends UserInfo {
  @override
  final DocumentReference gameRef = GameService().gameRef;

  @override
  final String userId;

  UserInfoService({this.userId});

  @override
  makeAdmin() async {
    print("des es de admin");
    return await gameRef
        .collection("users")
        .document(userId)
        .updateData({"admin": true});
  }

  @override
  UserData userDataFromSnapshot(DocumentSnapshot snapshot) {
    print(
        "got user data: ${snapshot.data['username']}, isAdmin = ${snapshot.data['admin']}");
    return UserData(
      userId: snapshot.documentID ?? "",
      username: snapshot.data['name'] ?? "",
      isAdmin: snapshot.data["admin"] ?? false,
      isTagger: snapshot.data["tagger"] ?? false,
    );
  }

  @override
  Stream<UserData> get userData {
    return gameRef
        .collection("users")
        .document(userId)
        .snapshots()
        .map(userDataFromSnapshot)
        .handleError((onError) => onError);
  }

  @override
  Future updateUserData(String username) async {
    return await gameRef
        .collection("users")
        .document(userId)
        .setData({"username": username});
  }

  @override
  deleteAccount() async {
    return await gameRef.collection("users").document(userId).delete();
  }
}
