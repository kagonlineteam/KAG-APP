import 'dart:async';
import 'dart:convert';

import 'api_models.dart';
import 'api_raw.dart' show getFromAPI;

class ListResource<Resource> {
  final String path;
  final Map<String, String> params;
  final int limit;


  final StreamController _stream = new StreamController();
  List<Resource> _content = [];
  int _loaded = 0;

  ListResource(this.path, this.params, {this.limit=20});
  
  ListResource.load(this.path, this.params, {this.limit=20}) {
    loadMore();
  }
  
  
  Future<void> loadMore() async {
    //TODO if authenticated paths are required set jwt here
    String rawResponse = await getFromAPI(path, {"limit": limit.toString(), "offset": _loaded.toString()}..addAll(params), null);
    // If not JSON just tell the Stream
    if (!rawResponse.startsWith("{")) {
      _stream.addError("Invalid API Response. API Response is not JSON");
      return;
    }
    // Parse JSON
    Map<dynamic, dynamic> resp = jsonDecode(rawResponse);
    if (resp['entities'].length > 0) {
      for (var entity in resp['entities']) {
        _content.add(fromJSON<Resource>(entity));
      }
    }
    _loaded = _loaded + resp['found'];
    _stream.add(_content);
  }
  
  void reload() {
    _content = [];
    _loaded = 0;
    loadMore();
  }

  int get loaded => _loaded;

  Stream get stream => _stream.stream;
}


/// This method is a helper to execute .fromJSON on a object if the
/// specific type is unknown at compiler time
/// This is used in ListResource
Resource fromJSON<Resource>(Map<dynamic, dynamic> rawJSON) {
  switch(Resource) {
    case Termin:
      return Termin.fromJSON(rawJSON) as Resource;
    case VPlan:
      return VPlan.fromJSON(rawJSON) as Resource;
    case Lesson:
      return Lesson.fromJSON(rawJSON) as Resource;
    case KAGUser:
      return KAGUser.fromJSON(rawJSON) as Resource;
    case MockModel:
      return MockModel.fromJSON(rawJSON) as Resource;
    default:
      throw UnimplementedError("This type is not implemented in fromJSON");
  }
}