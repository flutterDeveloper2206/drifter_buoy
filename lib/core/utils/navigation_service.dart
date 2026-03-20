import 'package:flutter/widgets.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static BuildContext? get currentContext => navigatorKey.currentContext;
}
