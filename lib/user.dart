class UserProfile {
  String? username;
  String? fullName;

  UserProfile FromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['fullname'];
    return this;
  }
}
