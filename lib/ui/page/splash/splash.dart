import 'dart:async';

import 'package:aimigo/data/get_storage.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/check_update.dart';
import 'package:aimigo/data/repository/app_version.dart';
import 'package:aimigo/package_info.dart';
import 'package:get/get.dart';

import '../../route.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? t;

  // and later, before the timer goes off...

  @override
  void dispose() {
    super.dispose();
    t?.cancel();
  }

  bool isHideVersion(int versionCode) {
    final int isHideVersion = getStorage.read('isHideVersion') ?? -1;
    return isHideVersion == versionCode;
  }

  checkUpdate() async {
    try {
      final appVersion = await AppRepository.get().getAppVersion();
      if (appVersion.code == 200) {

        if (appVersion.data.isHasNewVersion(packageInfo) && !isHideVersion(appVersion.data.versionCode)) {
          showDialog(
              context: Get.context!,
              barrierDismissible: !appVersion.data.isForce,
              builder: (context) => UpdateDialog(appVersion: appVersion.data));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: Center(child: Image(image: AssetImage("assets/images/logo.png"))),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      checkUpdate();
    }
    t = Timer(Duration(milliseconds: 250), () {
      // LoginRepository.getInstance().ticket.then((ticket) {
      //   var route = ticket == null ? AppRoute.loginPage : AppRoute.mainPage;
      //
      // });
      Navigator.pushReplacementNamed(context, AppRoute.mainPage,
          arguments: false);
    });
  }
}
