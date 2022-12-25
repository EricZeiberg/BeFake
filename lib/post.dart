import 'dart:io';

import 'package:befake/http.dart';
import 'package:befake/login.dart';
import 'package:befake/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with WidgetsBindingObserver {
  UserProfile profile = UserProfile();
  BeRealHTTP API = BeRealHTTP();
  List<UserProfile> friends = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    updateView();
    super.initState();
  }

  void updateView() {
    API.getFriends().then((value) => friends = value);
    API
        .getUserProfile()
        .then((value) => profile = value)
        .whenComplete(() => {setState(() => {})});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      updateView();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: (() => SignOut(context)),
              label: const Text("Sign Out"),
            ),
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("BeFake.")),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(children: [
                Center(
                  child: Stack(
                    children: [
                      buildImage(profile.profilePicURL, 120, 120),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                buildName(),
                ElevatedButton(
                    onPressed: OpenPhotoDialog,
                    child: const Text("Post Photo")),
                const Divider(
                  height: 15,
                  thickness: 1,
                  indent: 20,
                  endIndent: 0,
                  color: Colors.grey,
                ),
                ListView.builder(
                  itemBuilder: buildFriendListTile,
                  itemCount: friends.length,
                  shrinkWrap: true,
                )
              ]),
            )));
  }

  void SignOut(BuildContext context) {
    API.logOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void OpenPhotoDialog() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildPostPhotoDialog(file);
          });
    }
  }

  Widget buildPostPhotoDialog(File file) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Image.file(file),
              ElevatedButton(
                onPressed: (() => PostPhoto(file)),
                child: const Text("Upload"),
              )
            ],
          ),
        ));
  }

  void PostPhoto(File f) {
    API.uploadPhoto(f, profile.userId ?? "");
  }

  Widget buildImage(String? url, double? w, double? h) {
    Widget image;
    if (url == null) {
      image = Image(
        image: const AssetImage("assets/gray.png"),
        width: w,
        height: h,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        placeholder: ((context, url) => const CircularProgressIndicator()),
        fit: BoxFit.cover,
        width: w,
        height: h,
      );
    }

    return ClipOval(
      child: Material(color: Colors.transparent, child: image),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            profile.fullName ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            profile.username ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buildEmojis(),
          )
        ],
      );
  List<Widget> buildEmojis() {
    List<Widget> widgets = [];
    for (var map in profile.emojiReactImages.entries) {
      widgets.add(Column(
        children: [
          buildImage(map.value, 50, 50),
          const SizedBox(
            height: 1,
          ),
          Text(
            map.key,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ));
    }
    return widgets;
  }

  Widget buildFriendListTile(BuildContext context, int index) {
    var friend = friends[index];
    return ListTile(
      leading:
          Hero(tag: index, child: buildImage(friend.profilePicURL, 50, 50)),
      title: Text(friend.fullName ?? ""),
      subtitle: Text(friend.username ?? ""),
    );
  }
}
