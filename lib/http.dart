import 'dart:io';

import 'package:befake/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';

const String GAPI_KEY = "AIzaSyDwjfEeparokD7sXPVQli9NsTuhT6fJ6iA";
const String API_URL = "https://mobile.bereal.com/api";
final Headers = <String, String>{
  "user-agent": "BeReal/0.25.1 (iPhone; iOS 16.0.2; Scale/2.00)",
  "x-ios-bundle-identifier": "AlexisBarreyat.BeReal",
};

class BeRealHTTP {
  static String otp_sessionInfo = "";
  static String token = "";

  Future<bool> request2FACode(String number) async {
    final response = await http.post(
      Uri.parse(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/sendVerificationCode?key=$GAPI_KEY'),
      headers: Headers,
      body: jsonEncode(<String, String>{
        "phoneNumber": "+1$number",
        "iosReceipt":
            "AEFDNu9QZBdycrEZ8bM_2-Ei5kn6XNrxHplCLx2HYOoJAWx-uSYzMldf66-gI1vOzqxfuT4uJeMXdreGJP5V1pNen_IKJVED3EdKl0ldUyYJflW5rDVjaQiXpN0Zu2BNc1c",
      }),
    );
    if (response.statusCode == 200) {
      otp_sessionInfo = jsonDecode(response.body)['sessionInfo'];
      return true;
    } else {
      return false;
    }
  }

  Future<bool> send2FACode(String code) async {
    if (otp_sessionInfo != "") {
      final response = await http.post(
        Uri.parse(
            'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPhoneNumber?key=$GAPI_KEY'),
        headers: Headers,
        body: jsonEncode(<String, String>{
          "sessionInfo": otp_sessionInfo,
          "code": code,
          "operation": "SIGN_UP_OR_IN",
        }),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("idToken", res['idToken']);
        token = res['idToken'];
        prefs.setString("refresh_token", res['refreshToken']);
        prefs.setInt(
            "expiration",
            DateTime.now()
                .add(Duration(seconds: int.parse(res['expiresIn'])))
                .microsecondsSinceEpoch);
        prefs.setString("user_id", res['localId']);
        prefs.setString("phone", res['phoneNumber']);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("refresh_token")) {
      final response = await http.post(
          Uri.parse(
              "https://securetoken.googleapis.com/v1/token?key=$GAPI_KEY"),
          headers: Headers,
          body: jsonEncode(<String, String>{
            "refresh_token": prefs.getString("refresh_token") ?? "",
            "grant_type": "refresh_token"
          }));
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        prefs.setString("idToken", res['id_token']);
        token = res['id_token'];
        prefs.setString("refresh_token", res['refresh_token']);
        prefs.setInt(
            "expiration",
            DateTime.now()
                .add(Duration(seconds: int.parse(res['expires_in'])))
                .microsecondsSinceEpoch);
        prefs.setString("user_id", res['user_id']);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<UserProfile> getUserProfile() async {
    refreshToken();
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("$API_URL/person/me"),
        headers: <String, String>{
          "authorization": prefs.getString("idToken") ?? ""
        });
    if (response.statusCode == 200) {
      return UserProfile().FromJson(jsonDecode(response.body));
    } else {
      return UserProfile();
    }
  }

  Future<List<UserProfile>> getFriends() async {
    List<UserProfile> friends = [];
    refreshToken();
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse("$API_URL/relationships/friends"),
        headers: <String, String>{
          "authorization": prefs.getString("idToken") ?? ""
        });
    if (response.statusCode == 200) {
      List json = jsonDecode(response.body)['data'];
      for (var obj in json) {
        friends.add(UserProfile().FriendFromJson(obj));
      }
    }
    return friends;
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("idToken", "");
    prefs.setString("refresh_token", "");
    prefs.setInt("expiration", 0);
    prefs.setString("user_id", "");
    prefs.setString("phone", "");
  }

  Future<bool> checkLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("idToken") && prefs.getString("idToken") != "") {
      var timeNow = DateTime.now().microsecondsSinceEpoch;
      if (prefs.containsKey("expiresIn")) {
        if (timeNow >= (prefs.getInt("expiresIn") ?? 0)) {
          prefs.setString("idToken", "");
          return false;
        }
      }
      return true;
    }
    return false;
  }

  Future<String?> UploadPhoto(File file, String userID) async {
    Uint8List fileBytes = file.readAsBytesSync();
    String length = fileBytes.length.toString();
    var uuid = const Uuid();
    var name =
        "Photos/$userID/bereal/${uuid.v4()}-${DateTime.now().millisecondsSinceEpoch}.webp";
    var json_data = <String, dynamic>{
      "cacheControl": "public,max-age=172800",
      "contentType": "image/webp",
      "metadata": {"type": "bereal"},
      "name": name,
    };
    var headers = <String, String>{
      "x-goog-upload-protocol": "resumable",
      "x-goog-upload-command": "start",
      "x-firebase-storage-version": "ios/9.4.0",
      "x-goog-upload-content-type": "image/webp",
      "Authorization": "Firebase $token",
      "x-goog-upload-content-length": length,
      "content-type": "application/json",
      "x-firebase-gmpid": "1:405768487586:ios:28c4df089ca92b89",
    };

    var uri =
        "https://firebasestorage.googleapis.com/v0/b/storage.bere.al/o/${Uri.encodeComponent(name)}?uploadType=resumable&name=$name";

    final response = await http.post(Uri.parse(uri),
        headers: headers, body: jsonEncode(json_data));
    if (response.statusCode == 200) {
      var upload_url = response.headers['x-goog-upload-url'];
      var upload_headers = <String, String>{
        "x-goog-upload-command": "upload, finalize",
        "x-goog-upload-protocol": "resumable",
        "x-goog-upload-offset": "0",
        "content-type": "image/jpeg",
      };
      if (upload_url != null) {
        final photoPut = await http.put(Uri.parse(upload_url),
            headers: upload_headers, body: fileBytes);
        if (photoPut.statusCode == 200) {
          var json = jsonDecode(photoPut.body);
          print(json);
          return "https://${json['bucket']}/${json['name']}";
        }
      }
    }
  }

  Future<bool> CreatePost(File primary, File secondary, String userID) async {
    var primaryURL = await UploadPhoto(primary, userID);
    var secondaryURL = await UploadPhoto(secondary, userID);
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}Z";
    var json_data = {
      "isPublic": false,
      "isLate": false,
      "retakeCounter": 0,
      "takenAt": convertedDateTime,
      "location": {"latitude": "0", "longitude": "0"},
      "caption": "Insert caption here",
      "backCamera": {
        "bucket": "storage.bere.al",
        "height": 2000,
        "width": 1500,
        "path": primaryURL?.replaceFirst("https://storage.bere.al/", ""),
      },
      "frontCamera": {
        "bucket": "storage.bere.al",
        "height": 2000,
        "width": 1500,
        "path": secondaryURL?.replaceFirst("https://storage.bere.al/", ""),
      },
    };

    final response = await http.post(Uri.parse("$API_URL/content/post"),
        headers: <String, String>{
          "authorization": prefs.getString("idToken") ?? "",
          "content-type": "application/json"
        },
        body: jsonEncode(json_data));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return true;
    } else {
      return false;
    }
  }
}
