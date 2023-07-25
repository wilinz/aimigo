import 'package:flutter/cupertino.dart';
import 'package:flutter_template/ui/page/regiester/register.dart';

import 'page/login/login.dart';
import 'page/main/main.dart';
import 'page/splash/splash.dart';

class AppRoute {
  static String currentPage = splashPage;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String loginPage = "loginPage";

  static const String splashPage = "/";

  static const String mainPage = "mainPage";

  static const String registerPage = "registerPage";

  ///路由表配置
  static Map<String, Widget Function(BuildContext context, dynamic arguments)>
      routes = {
    loginPage: (context, arguments) {
      final args = arguments;
      final popUpAfterSuccess = args as bool;
      return LoginPage(popUpAfterSuccess: popUpAfterSuccess);
    },
    splashPage: (context, arguments) => const SplashPage(),
    mainPage: (context, arguments) => const MainPage(),
    registerPage: (context, arguments) {
      dynamic args = arguments;
      return RegisterPage(
          popUpAfterSuccess: true,
          username: args['username'] ?? '',
          password: args['password'] ?? '');
    },
  };
}
