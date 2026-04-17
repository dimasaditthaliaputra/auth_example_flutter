// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;

Widget buildWebSafeImage(String url) {
  final String viewId = 'google-img-$url';

  // Daftarkan HtmlElementView factory
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    return html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.border = 'none';
  });

  return HtmlElementView(viewType: viewId);
}
