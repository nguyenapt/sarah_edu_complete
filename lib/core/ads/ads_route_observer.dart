import 'package:flutter/widgets.dart';

import 'ads_manager.dart';

class AdsRouteObserver extends NavigatorObserver {
  AdsRouteObserver(this._ads);

  final AdsManager _ads;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _ads.onRouteChanged(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _ads.onRouteChanged(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _ads.onRouteChanged(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

