import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:aimigo/data/model/app/app_version/app_version.dart';
import 'package:aimigo/data/model/user/user.dart';
import 'package:aimigo/data/repository/app_version.dart';
import 'package:aimigo/data/repository/user.dart';
import 'package:aimigo/package_info.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<AppVersion?> appVersion = Rx<AppVersion?>(null);

  Stream<User?> getActiveUserStream() =>
      UserRepository.getInstance().getActiveUserStream();

  Future<dynamic> logout() async {
    try {
      final resp = await UserRepository.getInstance().logout();
      if (resp['code'] == 200) {
        Get.snackbar("成功", "");
      } else {
        Get.snackbar("失败", resp['msg']);
      }
    } catch (e, st) {
      Get.snackbar("失败", e.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) {
      checkUpdate();
    }
  }

  Future<void> checkUpdate() async {
    try {
      final appVersion = await AppRepository.get().getAppVersion();
      if (appVersion.code == 200) {
        this.appVersion.value = appVersion.data;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
