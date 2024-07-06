import 'package:aimigo/ui/page/audio/transcriptions.dart';
import 'package:aimigo/ui/page/audio/tts.dart';
import 'package:aimigo/ui/page/image/dalle.dart';
import 'package:aimigo/ui/page/new_post/new_post_page.dart';
import 'package:aimigo/ui/page/sponsor/sponsor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/ui/page/ai_painting/sd_model/sd_model_detail_page.dart';
import 'package:aimigo/ui/page/ai_painting/sd_model/sd_model_page.dart';
import 'package:aimigo/ui/page/ai_painting/text2img.dart';
import 'package:aimigo/ui/page/chat/chat.dart';
import 'package:aimigo/ui/page/image_details_page/image_details_page.dart';
import 'package:aimigo/ui/page/regiester/register.dart';
import 'package:aimigo/ui/page/reset_password/reset_password.dart';
import 'package:aimigo/ui/page/settings/settings_page.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:window_manager/window_manager.dart';

import 'page/login/login.dart';
import 'page/main/main.dart';
import 'page/splash/splash.dart';

class AppRoute {
  static String currentPage = splashPage;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String loginPage = "/loginPage";

  static const String registerPage = "/registerPage";

  static const String resetPasswordPage = "/ResetPasswordPage";

  static const String splashPage = "/";

  static const String mainPage = "/mainPage";

  static const String settingsPage = "/SettingsPage";

  static const String chatPage = "/ChatPage";

  static const String imageDetailsPage = "/ImageDetailsPage";

  static const String text2ImgPage = "/Text2ImgPage";

  static const String sdModelPage = "/SDModelPage";

  static const String sdModelDetailPage = "/SDModelDetailPage";

  static const String postPage = "/PostPage";

  static const String sponsorPage = "/SponsorPage";

  static const String imagePage = "/imageEPage";

  static const String audioTTSPage = "/audioTTSPage";

  static const String transcriptionsPage = "/transcriptionsPage";

  // ///路由表配置
  // static Map<String, Widget Function(BuildContext context, dynamic arguments)>
  //     routes = {
  //   loginPage: (context, arguments) {
  //     final args = arguments;
  //     final popUpAfterSuccess = args as bool;
  //     return LoginPage();
  //   },
  //   splashPage: (context, arguments) => const SplashPage(),
  //   mainPage: (context, arguments) => const MainPage(),
  //   settingsPage: (context, arguments) => SettingsPage(),
  //   registerPage: (context, arguments) {
  //     dynamic args = arguments;
  //     return RegisterPage(
  //         username: args['username'] ?? '', password: args['password'] ?? '');
  //   },
  //   resetPasswordPage: (context, arguments) =>
  //       ResetPasswordPage(username: arguments['username'] ?? ""),
  //   chatPage: (context, arguments) => ChatPage(),
  //   imageDetailsPage: (context, arguments) => ImageDetailsPage(data: arguments),
  //   text2ImgPage: (context, arguments) => Text2ImgPage(),
  //   sdModelPage:  (context, arguments) => SDModelPage(),
  //   sdModelDetailPage: (context, arguments) => SDModelDetailPage(model: arguments),
  // };

  static List<GetPage> routes = [
    GetPage(
      name: transcriptionsPage,
      page: () => TranscriptionsPage(),
    ),
    GetPage(
      name: audioTTSPage,
      page: () => TTSPage(),
    ),
    GetPage(
      name: imagePage,
      page: () => ImagePage(),
    ),
    GetPage(
      name: loginPage,
      page: () => LoginPage(),
    ),
    GetPage(
      name: sponsorPage,
      page: () => SponsorPage(),
    ),
    GetPage(
      name: postPage,
      page: () => PostPage(),
    ),
    GetPage(
      name: splashPage,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: mainPage,
      page: () => const MainPage(),
    ),
    GetPage(
      name: settingsPage,
      page: () => SettingsPage(),
    ),
    GetPage(
      name: registerPage,
      page: () => RegisterPage(
          username: Get.arguments['username'],
          password: Get.arguments['password']),
    ),
    GetPage(
      name: resetPasswordPage,
      page: () => ResetPasswordPage(username: Get.arguments['username']),
    ),
    GetPage(
      name: chatPage,
      page: () => ChatPage(),
    ),
    GetPage(
      name: imageDetailsPage,
      page: () => ImageDetailsPage(data: Get.arguments),
    ),
    GetPage(
      name: text2ImgPage,
      page: () => Text2ImgPage(model: Get.arguments),
    ),
    GetPage(
      name: sdModelPage,
      page: () => SDModelPage(),
    ),
    GetPage(
      name: sdModelDetailPage,
      page: () => SDModelDetailPage(model: Get.arguments),
    ),
  ].map((e) => e.copy(middlewares: [WindowTopBarMiddleWare()])).toList();
}

class WindowTopBarMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  @override
  Widget onPageBuilt(Widget page) {
    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      return Scaffold(
        appBar: buildWindowTopBar('app_name'.tr),
        body: page,
      );
    } else {
      return page;
    }
  }

  PreferredSizeWidget buildWindowTopBar(String title) {
    if (GetPlatform.isMacOS) {
      return PreferredSize(
        child: SizedBox(
          height: kWindowCaptionHeight,
          child: Center(child: Text(title)),
        ),
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
      );
    } else {
      return PreferredSize(
        child: WindowCaption(
          brightness: Get.theme.brightness,
          title: Text(title),
        ),
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
      );
    }
  }
}
