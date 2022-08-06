import 'package:flutter/material.dart';

import '../api/api.dart';
import '../components/helpers.dart';
import '../components/informations.dart';

class Information extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Informationen von A bis Z"),
        ),
        body: ResourceListBuilder(
            API.of(context).requests.getInformation,
                (data, controller) => ListView(
              controller: controller,
              children: [
                Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Wrap(
                    children: data.map<Widget>((information) => InformationListEntry(information)).toList(),
                  ),
                )],
            )
        )
    );
  }
}