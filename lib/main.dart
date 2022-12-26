import 'package:befake/http.dart';
import 'package:befake/login.dart';
import 'package:befake/post.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BeRealHTTP API = BeRealHTTP();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: API.checkLogIn(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            var isLoggedIn = snapshot.data;
            if (isLoggedIn ?? false) {
              return const HomeWidget();
            } else {
              return const LoginPage();
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
