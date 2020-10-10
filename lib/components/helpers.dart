import 'package:flutter/material.dart';
import '../api/api_helpers.dart';

const BorderSide splittingBorder      = const BorderSide(color: Color.fromRGBO(47, 109, 29, 1), width: 2);
Container splittingContainer    = Container(margin: EdgeInsets.fromLTRB(10, 0, 10, 0), decoration: BoxDecoration(border: Border(top: splittingBorder)));

// Used e.g. in RPlan
class ErrorTextHolder extends StatelessWidget {
  ErrorTextHolder(this._error, {this.barActions = const [], this.barTitle = ""});

  final String _error;
  final String barTitle;
  final List<Widget> barActions;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(actions: barActions, title: Text(barTitle)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(_error, textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }

  String get error => _error;
}

class ResourceListBuilder<Resource> extends StatelessWidget {

  final ListResource resource;
  final ScrollController scrollController;
  final Widget Function(List<Resource>, ScrollController scrollController) builder;
  final String errorMessage;

  ResourceListBuilder(resourceFunction, this.builder, {this.errorMessage = "Die Daten sind zur Zeit nicht verfügbar"}):
      resource = resourceFunction(),
      scrollController = ScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
        resource.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => resource.reload(),
        child: StreamBuilder(
          stream: resource.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(errorMessage));
            } else if (!snapshot.hasData) {
              return Stack(children: [
                Center(child: Image.asset("assets/eule-rund.png")),
                Center(child: CircularProgressIndicator())
              ]);
            } else {
              return builder(snapshot.data, scrollController);
            }
          },
        ),
      ),
    );
  }
}