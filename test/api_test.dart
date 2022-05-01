import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kag/api/api.dart';
import 'package:kag/api/api_helpers.dart';
import 'package:kag/api/api_models.dart' show MockModel;
import 'package:kag/api/api_raw.dart' as raw;
import 'package:mockito/mockito.dart';

class MockClient extends Mock implements http.Client {}
class MockUser extends Mock implements User {}

void main() {
  raw.client = MockClient();

  test('test raw get', () async {
    when(raw.client.get(any, headers: {"Authorization": "Bearer 123"})).thenAnswer((_) async => http.Response('testResponse1', 200));
    expect(await raw.getFromAPI("request", {"test": "param", "param": "test"}, "123"), "testResponse1");
    when(raw.client.get(any, headers: null)).thenAnswer((_) async => http.Response('testResponse2', 200));
    expect(await raw.getFromAPI("request", {"test": "param", "param": "test"}, null), "testResponse2");
    when(raw.client.get(any, headers: null)).thenAnswer((_) async => http.Response('testResponse3', 400));
    expect(() => raw.getFromAPI("request", {"test": "errorCode"}, null), throwsException);
  });

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

    when(raw.client.get(any, headers: anyNamed("headers"))).thenAnswer((_) async => http.Response('{"found": 5, "max": 100, "entities": [{"ping": "mock"}]}', 200));

    await resource.loadMore();
    expect(resource.loaded, 5);
    when(raw.client.get(any, headers: anyNamed("headers"))).thenAnswer((_) async => http.Response('{"found": 2, "max": 98, "entities": [{"pong": "mock"}]}', 200));
    await resource.loadMore();
    expect(resource.loaded, 7);
  });
}