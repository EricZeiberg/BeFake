import 'package:befake/http.dart';
import 'package:befake/post.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool is2FAVisible = false;
  String buttonText = "Sign In";
  final phoneNumberController = TextEditingController();
  final authCodeController = TextEditingController();

  final BeRealHTTP API = BeRealHTTP();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent, title: const Text("BeFake.")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your phone number',
                ),
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
              ),
            ),
            Visibility(
              visible: is2FAVisible,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 40, top: 0, right: 40, bottom: 10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter the 6 digit code',
                  ),
                  keyboardType: TextInputType.number,
                  controller: authCodeController,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: (() => onSignInButton(context)),
                  child: Text(buttonText)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onSignInButton(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("idToken")) {
      String buttonTextString = await API.getUsername();
      setState(() {
        buttonText = buttonTextString;
      });
      return;
    }
    if (is2FAVisible) {
      bool send2FACode = await API.send2FACode(authCodeController.text);
      if (send2FACode) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PostWidget()));
      } else {
        setState(() {
          is2FAVisible = false;
          buttonText = "Sign In";
        });
        return;
      }
    }
    bool is2FAVisibleBool =
        await API.request2FACode(phoneNumberController.text);

    setState(() {
      is2FAVisible = is2FAVisibleBool;
      buttonText = "Send 2FA Code";
    });
  }
}
