import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../api/api_models.dart';
import 'pages.dart';
import 'views.dart';

class AppTypeState {
  final AppType _appType;
  // Contains the pages that should
  // explicitly not be displayed
  // (e.g. because of missing permissions)
  // this can include pages not present

  final List<AppPage> _shown;

  AppTypeState(this._appType, List<AppPage> hide) :
    _shown = AppViews(_appType) {
    for (AppPage hidden in hide) {
      _shown.remove(hidden);
    }
  }

  AppType get appType => _appType;

  List<AppPage> get pages => _shown;

  int get length => _shown.length;

  List<Widget> getAppViews() {
    return _shown.map(getPageWidget).toList();
  }

  int getPageNumber(AppPage page) {
    int number = _shown.indexOf(page);
    if (number == -1) return 0;
    return number;
  }

}

enum AppPage {
  HOME,
  CALENDAR,
  NEWS,
  SPLAN,
  RPLAN,
  HOMEWORK,
  WEBMAIL,
  LOGIN,
  PRIVACY_INFO
}

enum AppType {
  LOGGED_OUT,
  NORMAL,
  VPLAN_LOGGED_OUT,
  VPLAN,
  MOBILE_SITE
}

AppTypeState getStateForUser(AppType type, KAGUser user) {
  List<AppPage> hide = [];
  if (user == null || !user.mailConsent) hide.add(AppPage.WEBMAIL);
  if (user == null || !user.homeworkConsent) hide.add(AppPage.HOMEWORK);
  if (!kIsWeb) hide.add(AppPage.PRIVACY_INFO);
  return AppTypeState(type, hide);
}
