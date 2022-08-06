import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Views/News.dart';
import '../api/api_models.dart';
import '../api/api_raw.dart' as raw_api;

class InformationListEntry extends StatelessWidget {
  final Article information;

  InformationListEntry(this.information);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(information.title),
      leading:
      information.imageID != null ?
      ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: CachedNetworkImage(
          imageUrl: "${raw_api.API}files/${information.imageID}",
          width: 50,
        ),
      ) :
      Padding(
        child: Icon(Icons.info, size: 30),
        padding: EdgeInsets.all(10),
      ),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => ArticleDetail(information))),
    );
  }
}