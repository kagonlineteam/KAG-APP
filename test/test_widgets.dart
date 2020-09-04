import 'package:kag/api/api.dart';
import 'package:kag/main.dart';

import 'common_mocks.dart';


void main() {
  // This needs to be in the new Inherited Widget
  API api = API.asMock(createMockUser(), createMockAPIRequests(KAGApp.api));
}