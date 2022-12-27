import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../http.dart';
import '../userprofile.dart';
import '../utils.dart';

class FriendsWidget extends StatefulWidget {
  const FriendsWidget({super.key});

  @override
  State<FriendsWidget> createState() => _FriendsWidgetState();
}

class _FriendsWidgetState extends State<FriendsWidget>
    with WidgetsBindingObserver {
  List<UserProfile> friends = [];
  BeRealHTTP API = BeRealHTTP();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: buildFriendListTile,
      itemCount: friends.length,
      shrinkWrap: true,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    updateView();
    super.initState();
  }

  void updateView() {
    API
        .getFriends()
        .then((value) => friends = value)
        .whenComplete(() => {setState(() => {})});
    ;
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

  Widget buildFriendListTile(BuildContext context, int index) {
    var friend = friends[index];
    return ListTile(
      leading: Hero(
          tag: index, child: Utils.buildImage(friend.profilePicURL, 50, 50)),
      title: Text(friend.fullName ?? ""),
      subtitle: Text(friend.username ?? ""),
    );
  }
}
