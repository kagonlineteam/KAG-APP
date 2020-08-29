import 'package:flutter_test/flutter_test.dart';
import 'package:kag/api/api_helpers.dart';
import 'package:kag/api/api_models.dart' show MockModel;
import 'package:http/http.dart' as http;
import 'package:kag/api/api_raw.dart' as raw show API, client;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}


void main() {
  raw.client = MockClient();

  test('test list resource', () async {
    ListResource resource = ListResource<MockModel>("mock", {"testParam": "test"});

    expect(resource.stream.isBroadcast, false);

    // Verify limit exists and makes sense
    expect(resource.limit, isNotNull);
    expect(resource.limit, isNonNegative);
    expect(resource.limit, isNonZero);

    resource.stream.listen(
      expectAsync1((event) {
        expect(event.length, greaterThanOrEqualTo(1));
        expect(event[0].rawJSON, contains("ping"));
        if (event.length == 2) {
          expect(event[1].rawJSON, contains("pong"));
        }
      }, count: 2),
    );

    when(raw.client.get("${raw.API}mock?limit=${resource.limit}&offset=0&testParam=test", headers: anyNamed("headers"))).thenAnswer((_) async => http.Response('{"found": 5, "max": 100, "entities": [{"ping": "mock"}]}', 200));
    when(raw.client.get("${raw.API}mock?limit=${resource.limit}&offset=5&testParam=test", headers: anyNamed("headers"))).thenAnswer((_) async => http.Response('{"found": 2, "max": 98, "entities": [{"pong": "mock"}]}', 200));

    await resource.loadMore();
    expect(resource.loaded, 5);
    await resource.loadMore();
    expect(resource.loaded, 7);
  });
}