import 'package:befake/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> updateView() async {
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
    return RefreshIndicator(
      onRefresh: updateView,
      child: ListView.builder(
        itemBuilder: buildPostObject,
        itemCount: posts.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget buildPostObject(BuildContext context, int index) {
    var post = posts[index];
    return FeedObjectWidget(
      post: post,
      index: index,
    );
  }
}

class FeedObjectWidget extends StatefulWidget {
  final Post post;
  final int index;
  const FeedObjectWidget({Key? key, required this.post, required this.index})
      : super(key: key);

  @override
  State<FeedObjectWidget> createState() => _FeedObjectWidgetState();
}

class _FeedObjectWidgetState extends State<FeedObjectWidget> {
  var isSecondaryVisible = false;
  String postURL = "";

  @override
  void initState() {
    postURL = widget.post.primaryPhotoURL!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lateText = "On-Time";
    if (widget.post.isLate) {
      lateText = "Late";
    }

    return Column(
      children: [
        ListTile(
          leading: Hero(
              tag: widget.index,
              child: Utils.buildImage(widget.post.user?.profilePicURL, 30, 30)),
          title: Text(widget.post.user?.fullName ?? "",
              style: const TextStyle(fontSize: 18)),
          subtitle: Text(lateText),
        ),
        Stack(alignment: Alignment.bottomRight, children: [
          CachedNetworkImage(
            imageUrl: postURL,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            width: 1000,
            height: 500,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: (() => DownloadImage(context, postURL)),
                icon: const Icon(Icons.download),
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                onPressed: (() {
                  setState(() {
                    isSecondaryVisible = !isSecondaryVisible;
                    postURL = isSecondaryVisible
                        ? widget.post.secondaryPhotoURL!
                        : widget.post.primaryPhotoURL!;
                  });
                }),
                icon: const Icon(Icons.cameraswitch),
                color: Colors.white,
              ),
            ],
          )
        ]),
      ],
    );
  }

  Future<void> DownloadImage(BuildContext context, String imageURL) async {
    launchUrl(Uri.parse(imageURL));
  }
}
