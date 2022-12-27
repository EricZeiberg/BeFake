import 'package:befake/http.dart';
import 'package:befake/pages/feed.dart';
import 'package:befake/pages/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'friends.dart';
import 'login.dart';

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  final BeRealHTTP API = BeRealHTTP();

  void SignOut(BuildContext context) {
    API.logOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (() => SignOut(context)),
        label: const Text("Sign Out"),
      ),
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("BeFake."),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.face),
                  text: "Profile",
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: "Friends",
                ),
                Tab(
                  icon: Icon(Icons.feed),
                  text: "Feed",
                )
              ],
            ),
          ),
          body: const TabBarView(
            children: [PostWidget(), FriendsWidget(), FeedWidget()],
          ),
        ),
      ),
    );
  }
}
