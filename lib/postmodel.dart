import 'package:befake/userprofile.dart';

class Post {
  UserProfile? user;
  String? userID;
  String? primaryPhotoURL;
  String? secondaryPhotoURL;
  bool isLate = false;

  Post FromJson(Map<String, dynamic> json) {
    primaryPhotoURL = json['photoURL'];
    secondaryPhotoURL = json['secondaryPhotoURL'];
    userID = json['ownerID'];
    return this;
  }

  void SetUserProfile(UserProfile profile) {
    user = profile;
  }
}
