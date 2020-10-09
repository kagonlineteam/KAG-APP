import 'dart:html' as html;

import 'package:flutter/material.dart';
import '../../main.dart';

void openFile(BuildContext context, String file, String type) async {
  html.Blob blob = html.Blob([await KAGApp.api.requests.getFile(file)], type);
  html.window.open(html.Url.createObjectUrl(blob), 'file');
}