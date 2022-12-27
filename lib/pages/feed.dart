import 'package:befake/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../postmodel.dart';
import '../utils.dart';

class FeedWidget extends StatefulWidget {
  const FeedWidget({super.key});

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> with WidgetsBindingObserver {
  final BeRealHTTP API = BeRealHTTP();
  List<Post> posts = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    updateView();
    super.initState();
  }

  void updateView() {
    API.GetFeed()
        .then((value) => posts = value)
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
    return ListView.builder(
      itemBuilder: buildPostObject,
      itemCount: posts.length,
      shrinkWrap: true,
    );
  }

  Widget buildPostObject(BuildContext context, int index) {
    var post = posts[index];
    return Column(
      children: [
        ListTile(
          leading: Hero(
              tag: index,
              child: Utils.buildImage(post.user!.profilePicURL, 30, 30)),
          title: Text(post.user!.fullName ?? "",
              style: const TextStyle(fontSize: 18)),
        ),
        CachedNetworkImage(
          imageUrl: post.primaryPhotoURL ?? "",
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
          width: 1000,
          height: 500,
        ),
      ],
    );
  }
}
