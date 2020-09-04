import 'package:kag/api/api.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {}
class Requests extends Mock implements APIRequests {}

User createMockUser() {
  User user = MockUser();
  when(user.getUsername()).thenReturn("TestUser");
  when(user.getDecodedJWT()).thenReturn({
    "iat": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "exp": (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (60 * 15),
    "sub": "access_main",
    "user": "TestUser",
    "roles": [
      "ROLE_AUTHENTICATED",
      "ROLE_OBERSTUFE",
    ],
    "client": "appclient"
  });
  when(user.getGroups()).thenReturn([
    "ROLE_AUTHENTICATED",
    "ROLE_OBERSTUFE",
  ]);
  // This is just a token that looks like a jwt
  when(user.getJWT()).thenReturn("eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE1OTM2MzY5NjEsImV4cCI6MTU5MzYzNzU2MSwic3ViIjoiYWNjZXNzX21haW4iLCJ1c2VyIjoiU0ZlbGl4MTMiLCJyb2xlcyI6WyJST0xFX0FVVEhFTlRJQ0FURUQiLCJST0xFX0FETUlOSVNUUkFUT1IiXSwiY2xpZW50IjoibG9jYWxjbGllbnRpZCJ9.0KIPHbi-WswFj3aCLy5JFCbdhUEWCPYXpFnrg2SP5DoL2e1xGkQNCFgpQUgdXRdyctE1oMqJeJZsbAug6Dyz7M4WKlX1dsHkQQX6nLGuOZS_dlX0R_RnRwZ2RzUQS2vKmivvU6jMusvxSklfj6lbXQ1t-73tign9jckwR7mVbbtsiH7eR0pPogxweKrAH8aAt1_oPb8CDemBK_LLcPOJpBH7QWE5t4yfNaKNXwxs8uvZWb6kN3U5h6PVjN0P8AJzGCZH8gbJ4v_E_5e6WN-P5pG9xxNN7Jv47mXAliUsYuO2KoL30tlUuPFVdorW-N9p55dyclVZUVkUc8q_yp6Je-JHsy2Rk44Rd3594d5KHviXx7POgHa_YMtsvUUmBCAaajrLriYN7ANdyT93kVFS9b2hFh8kkoEgxp3yr8W1BOK4OXHPy3QacIBtg3sXAbR2tH56aWfTbyOcNoV_4T7mF6Z3VxYy6afIVzMwjyrTcyBfdJD3nV1RgXYwzicB6yMO_DYlZ3YBjHxRdA7dPu1zx6E9KqHb2BY9hebrHL8Ut53-GhZMW58wDWfHfYcqE7VPi_xgMqQy0Kp2lenKhrcK8uLiXs1H8USaG1nJvvh221q65GonqdRXIgG-b0O7PJl0u_9xeH0EYwElcd7biaZhFaMz7wQ8I1VveNnI5xJzIco");
  when(user.isLoggedIn()).thenReturn(true);
  when(user.setLoginCredentials(any, any)).thenAnswer((realInvocation) async {return false;});
  when(user.setLoginCredentials("TestUser", "password")).thenAnswer((realInvocation) async {return true;});
  when(user.login()).thenAnswer((realInvocation) async {return true;});
  return user;
}

APIRequests createMockAPIRequests(API api) {
  APIRequests apiRequests = APIRequests(api);
  return apiRequests;
}