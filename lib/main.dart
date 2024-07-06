import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aimigo/data/database/database.dart';
import 'package:aimigo/data/get_storage.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/package_info.dart';
import 'package:aimigo/ui/color_schemes.g.dart';
import 'package:aimigo/messages/messages.dart';
import 'package:aimigo/ui/page/settings/settings_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ui/route.dart';
import 'util/platform.dart';

Future<void> main() async {
  //确保组件树初始化
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initDatabase(),
    initDesktopWindows(),
    initPackageInfo(),
    () async {
      await initGetStorage();
      await AppNetwork.init();
    }(),
  ]);
  runApp(const MyApp());
}

Future<void> initDesktopWindows() async {
  if (!kIsWeb && PlatformUtil.isDesktop()) {
    final padding = 50;
    final screen = await getCurrentScreen();
    final height =
        (screen?.visibleFrame.height ?? 450 + padding * 2) - padding * 2;
    // 必须加上这一行。
    await windowManager.ensureInitialized();
    WindowOptions windowOptions =
        WindowOptions(size: Size(height * 0.5, height));

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMinimizable(true);
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setMaximizable(true);
      await windowManager.setResizable(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden,
          windowButtonVisibility: true);
      final position = await windowManager.getPosition();
      await windowManager
          .setPosition(Offset(position.dx - padding, position.dy));
      // await windowManager.setTitleBarStyle(TitleBarStyle.normal,windowButtonVisibility: true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

showSnackBar(BuildContext context, String msg, {int milliseconds = 2000}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      // action: SnackBarAction(label: '撤销', onPressed: Null),
      duration: Duration(milliseconds: milliseconds)));
}

class MyApp extends StatefulWidget with WindowListener {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final settings = Get.put(SettingsController(getStorage));

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return GetMaterialApp(
      title: 'Aimigo',
      translations: Messages(),
      defaultTransition: Transition.cupertino,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        settings.locale.value ?? Get.deviceLocale ?? Locale("zh", "CN"),
      ],
      // 转场动画
      // locale: Locale('en', 'US'),
      locale: settings.locale.value ?? Get.deviceLocale,
      fallbackLocale: Locale('zh', 'CN'),
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: settings.themeMode.value,
      // routes: AppRoute.routes,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRoute.navigatorKey,
      getPages: AppRoute.routes,
      // onGenerateRoute: (RouteSettings settings) {
      //   return MaterialPageRoute(builder: (context) {
      //     var routeName = settings.name!;
      //     AppRoute.currentPage = routeName;
      //     if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      //       return Scaffold(
      //         appBar: buildWindowTopBar(context, 'app_name'.tr),
      //         body: AppRoute.routes[routeName]!
      //             .call(context, settings.arguments),
      //       );
      //     } else {
      //       return AppRoute.routes[routeName]!
      //           .call(context, settings.arguments);
      //     }
      //   });
      // }
    );
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  StreamSubscription<ConnectivityResult>? subscription;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    subscription?.cancel();
    super.dispose();
  }
}

ScrollBehavior myScrollBehavior(BuildContext context) =>
    ScrollConfiguration.of(context).copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
    );
