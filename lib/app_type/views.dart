import 'app_type_managment.dart';

/// Used by main.dart
///

// ignore: non_constant_identifier_names
List<AppPage> AppViews(AppType type) {
  switch (type) {
    case AppType.LOGGED_OUT:
      return [
        AppPage.HOME,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.LOGIN,
      ];
    case AppType.NORMAL:
      return [
        AppPage.HOME,
        AppPage.PrivacyInfo,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.SPLAN,
        AppPage.RPLAN,
        AppPage.HOMEWORK,
        AppPage.WEBMAIL
      ];
    case AppType.VPLAN_LOGGED_OUT:
      return [
        AppPage.LOGIN
      ];
    case AppType.VPLAN:
      return [
        AppPage.RPLAN,
        AppPage.SPLAN
      ];
    case AppType.MOBILE_LOGGED_OUT:
      return [
        AppPage.PrivacyInfo,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.LOGIN,
      ];
    case AppType.MOBILE_SITE:
      return [
        AppPage.PrivacyInfo,
        AppPage.HOME,
        AppPage.CALENDAR,
        AppPage.NEWS,
        AppPage.SPLAN,
        AppPage.RPLAN
      ];
    default:
      return [];
  }
}