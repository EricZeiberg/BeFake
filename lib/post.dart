import 'package:befake/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  String username = "";
  BeRealHTTP API = BeRealHTTP();

  @override
  Widget build(BuildContext context) {
    updateUsername();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent, title: const Text("BeFake.")),
      body: Column(children: [Text(username)]),
    ));
  }

  void updateUsername() async {
    String usernameString = await API.getUsername();
    setState(() {
      username = usernameString;
    });
  }
}
