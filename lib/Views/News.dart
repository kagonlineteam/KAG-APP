import 'package:flutter/material.dart';
import 'package:kag/components/helpers.dart';

import '../api/api_helpers.dart';
import '../api/api_models.dart';
import '../components/news.dart';
import '../main.dart';

class News extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Aktuelles"),
        ),
        body: ResourceListBuilder(
            KAGApp.api.requests.getArticles,
            (data, controller) => ListView(
              controller: controller,
              children: [
                Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Wrap(
                    children: data.map<Widget>((article) => ArticleCard(article)).toList(),
                  ),
                )],
            )
        )
    );
  }
}

class ArticleDetail extends StatelessWidget {
  ArticleDetail(this.originArticle);

  final Article originArticle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: KAGApp.api.requests.getArticle(originArticle.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ArticleDetailWidget(snapshot.data);
        } else {
          return ArticleDetailWidget(originArticle);
        }
      },
    );
  }

}
