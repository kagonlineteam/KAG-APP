import 'dart:html' as html;

import 'package:flutter/material.dart';
import '../../api/api.dart';

void openFile(BuildContext context, String file, String type) async {
  html.Blob blob = html.Blob([await API.of(context).requests.getFile(file)], type);
  html.window.open(html.Url.createObjectUrl(blob), 'file');
}

void openIOSConfigFile(BuildContext context, String data) async {
  html.Blob blob = html.Blob([data], "text/xml");
  var url = html.Url.createObjectUrl(blob);
  html.AnchorElement anchorElement =  new html.AnchorElement(href: url);
  anchorElement.href = url;
  anchorElement.download = "kag_email.mobileconfig";
  anchorElement.click();
}