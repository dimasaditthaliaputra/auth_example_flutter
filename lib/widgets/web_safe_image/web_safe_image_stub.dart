import 'package:flutter/material.dart';

Widget buildWebSafeImage(String url) {
  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.person, color: Colors.white, size: 32);
    },
  );
}
