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
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'ui/route.dart';
import 'util/platform.dart';

Future<void> main() async {
  //确保组件树初始化
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initDatabase(),
    initDesktopWindows(),
    initGetStorage(),
    initPackageInfo(),
    AppNetwork.init()
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
      title: 'app_name'.tr,
      translations: Messages(),
      defaultTransition: Transition.cupertino,
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _counter.toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

ScrollBehavior myScrollBehavior(BuildContext context) =>
    ScrollConfiguration.of(context).copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
    );