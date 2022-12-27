import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Utils {
  static Widget buildImage(String? url, double? w, double? h) {
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
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
        width: w,
        height: h,
      );
    }

    return ClipOval(
      child: Material(color: Colors.transparent, child: image),
    );
  }
}
