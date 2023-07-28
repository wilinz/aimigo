import 'package:flutter/cupertino.dart';
import 'package:flutter_template/ui/page/chat/chat.dart';
import 'package:flutter_template/ui/page/regiester/register.dart';
import 'package:flutter_template/ui/page/reset_password/reset_password.dart';
import 'package:flutter_template/ui/page/settings/settings_page.dart';

import 'page/login/login.dart';
import 'page/main/main.dart';
import 'page/splash/splash.dart';

class AppRoute {
  static String currentPage = splashPage;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String loginPage = "/loginPage";

  static const String splashPage = "/";

  static const String mainPage = "/mainPage";

  static const String registerPage = "/registerPage";

  static const String settingsPage = "/SettingsPage";

  static const String resetPasswordPage = "/ResetPasswordPage";

  static const String chatPage = "/ChatPage";

  ///路由表配置
  static Map<String, Widget Function(BuildContext context, dynamic arguments)>
      routes = {
    loginPage: (context, arguments) {
      final args = arguments;
      final popUpAfterSuccess = args as bool;
      return LoginPage();
    },
    splashPage: (context, arguments) => const SplashPage(),
    mainPage: (context, arguments) => const MainPage(),
    settingsPage: (context, arguments) => SettingsPage(),
    registerPage: (context, arguments) {
      dynamic args = arguments;
      return RegisterPage(
          username: args['username'] ?? '', password: args['password'] ?? '');
    },
    resetPasswordPage: (context, arguments) =>
        ResetPasswordPage(username: arguments['username'] ?? ""),
    chatPage: (context, arguments) => ChatPage(),
  };
}
