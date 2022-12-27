import 'package:befake/userprofile.dart';
import 'package:befake/utils.dart';

class Post {
  UserProfile? user;
  String? userID;
  String? primaryPhotoURL;
  String? secondaryPhotoURL;
  bool isLate = false;

  Post FromJson(Map<String, dynamic> json) {
    primaryPhotoURL = "${Utils.GetProxyString()}/" + json['photoURL'];
    secondaryPhotoURL =
        "${Utils.GetProxyString()}/" + json['secondaryPhotoURL'];
    userID = json['ownerID'];
    if (json['mediaType'] == "late") {
      isLate = true;
    }
    return this;
  }

  void SetUserProfile(UserProfile profile) {
    user = profile;
  }
}
