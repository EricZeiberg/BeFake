import 'package:befake/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
          Uri.parse("https://securetoken.googleapis.com/v1/token?key$GAPI_KEY"),
          headers: Headers,
          body: jsonEncode(<String, String>{
            "refresh_token": prefs.getString("refresh_token") ?? "",
            "grant_type": "refresh_token"
          }));
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        prefs.setString("idToken", res['idToken']);
        token = res['idToken'];
        prefs.setString("refresh_token", res['refreshToken']);
        prefs.setInt(
            "expiration",
            DateTime.now()
                .add(Duration(seconds: int.parse(res['expiresIn'])))
                .microsecondsSinceEpoch);
        prefs.setString("user_id", res['localId']);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<UserProfile> getUserProfile() async {
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
}
