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
    profilePicURL = json['profilePicture']['url'];
    for (var emoji in json['realmojis']) {
      emojiReactImages.putIfAbsent(emoji['emoji'], () => emoji['media']['url']);
    }
    return this;
  }

  UserProfile FriendFromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['fullname'];
    userId = json['id'];
    try {
      profilePicURL = json['profilePicture']['url'];
    } on NoSuchMethodError {
      return this;
    }
    return this;
  }
}
