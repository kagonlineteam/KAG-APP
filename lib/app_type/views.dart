import 'app_type_managment.dart';

/// Used by main.dart
///

// ignore: non_constant_identifier_names
List<AppPage> AppViews(AppType type) {
  switch (type) {
    case AppType.LOGGED_OUT:
      print('Logged OUt');
      return [
        AppPage.HOME,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.LOGIN,
        AppPage.PRIVACY_INFO
      ];
    case AppType.NORMAL:
      print('Normal');
      return [
        AppPage.HOME,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.SPLAN,
        AppPage.RPLAN,
        AppPage.HOMEWORK,
        AppPage.WEBMAIL,
        AppPage.PRIVACY_INFO
      ];
    case AppType.VPLAN_LOGGED_OUT:
      return [
        AppPage.LOGIN,
        AppPage.PRIVACY_INFO
      ];
    case AppType.VPLAN:
      return [
        AppPage.RPLAN,
        AppPage.SPLAN,
        AppPage.PRIVACY_INFO
      ];
    case AppType.MOBILE_SITE:
      print('Mobile');
      return [
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.KRANKMELDUNG,
        AppPage.LOGIN,
        AppPage.PRIVACY_INFO
      ];
    default:
      return [];
  }
}