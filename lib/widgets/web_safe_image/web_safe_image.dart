import 'package:flutter/material.dart';

import 'web_safe_image_stub.dart'
    if (dart.library.html) 'web_safe_image_web.dart';

class WebSafeImage extends StatelessWidget {
  final String url;

  const WebSafeImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return buildWebSafeImage(url);
  }
}
