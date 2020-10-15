import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../api/api.dart';


void openFile(BuildContext context, String file, String type) async {
  String tempFile = "${(await getTemporaryDirectory()).path}/datei${type == "application/pdf" ? ".pdf" : ".file"}";
  if (await File(tempFile).exists()) {
    await File(tempFile).delete();
  }
  await File(tempFile).writeAsBytes(await API.of(context).requests.getFile(file));
  OpenFile.open(tempFile);
}