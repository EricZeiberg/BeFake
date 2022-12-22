import 'package:befake/http.dart';
import 'package:befake/login.dart';
import 'package:befake/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  UserProfile profile = UserProfile();
  BeRealHTTP API = BeRealHTTP();

  @override
  void initState() {
    API
        .getUserProfile()
        .then((value) => value = profile)
        .whenComplete(() => {setState(() => {})});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("BeFake.")),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(children: [
                Center(
                  child: Stack(
                    children: [
                      buildImage(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                buildName()
              ]),
            )));
  }

  void SignOut(BuildContext context) {
    API.logOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Widget buildImage() {
    const image = NetworkImage("https://picsum.photos/250?image=9");

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
        ),
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            profile.username ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            profile.fullName ?? "",
            style: TextStyle(color: Colors.grey),
          )
        ],
      );
}
