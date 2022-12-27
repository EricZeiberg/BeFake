import 'package:befake/pages/tabview.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:befake/http.dart';
import 'package:befake/pages/post.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool is2FAVisible = false;
  String buttonText = "Sign In";
  final phoneNumberController = TextEditingController();
  final authCodeController = TextEditingController();
  final BeRealHTTP API = BeRealHTTP();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Future<void> onSignInButton(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (is2FAVisible) {
      bool send2FACode = await API.send2FACode(authCodeController.text);
      if (send2FACode) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const TabView()));
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
