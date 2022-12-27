import 'package:befake/utils.dart';

class UserProfile {
  String? username;
  String? fullName;
  String? userId;
  String? profilePicURL;
  Map<String, String> emojiReactImages = <String, String>{};

  UserProfile FromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['fullname'];
    userId = json['id'];
    profilePicURL =
        "${Utils.GetProxyString()}/" + json['profilePicture']['url'];
    for (var emoji in json['realmojis']) {
      emojiReactImages.putIfAbsent(emoji['emoji'],
          () => "${Utils.GetProxyString()}/" + emoji['media']['url']);
    }
    return this;
  }

  UserProfile FriendFromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['fullname'];
    userId = json['id'];
    try {
      profilePicURL =
          "${Utils.GetProxyString()}/" + json['profilePicture']['url'];
    } on NoSuchMethodError {
      return this;
    }
    return this;
  }
}
