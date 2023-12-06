import 'package:aimigo/data/network.dart';
import 'package:aimigo/ui/page/settings/settings.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kt_dart/kt.dart';

import '../../../data/get_storage.dart';
import '../../color_schemes.g.dart';

extension LocaleExtensions on Locale {
  String toLocaleCode() {
    String languageCode = this.languageCode;
    String countryCode = this.countryCode ?? "";
    return "${languageCode}_$countryCode";
  }

  static Locale? LocaleFromCode(String? code) {
    if (code == null) return null;
    final localeParts = code.split('_');
    if (localeParts.length == 2) {
      return Locale(localeParts[0], localeParts[1]);
    }
    return null;
  }
}

class SettingsController extends GetxController {
  final GetStorage _storage;

  var themeMode = ThemeMode.system.obs;
  var locale = LocaleExtensions.LocaleFromCode(null).obs;
  final apikeyVisible = false.obs;

  final openaiBaseUrlController = TextEditingController();

  final apiKeyController = TextEditingController();

  SettingsController(this._storage);

  @override
  void onInit() {
    super.onInit();
    // 从存储中加载主题设置和语言设置
    _storage.read<int?>(AppSettings.themeKey)?.let((it) {
      themeMode.value = ThemeMode.values[it];
    });

    _storage.read<String?>(AppSettings.openaiApiKey)?.let((it) {
      apiKeyController.text = it;
    });

    _storage.read<String?>(AppSettings.openaiBaseUrl)?.let((it) {
      openaiBaseUrlController.text = it;
    });

    LocaleExtensions.LocaleFromCode(_storage.read(AppSettings.languageKey))
        ?.let((it) => locale.value = it);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    // Get.changeThemeMode(option);
    // 将主题设置保存到存储中
    _storage.write(AppSettings.themeKey, mode.index);
  }

  void changeLanguage(String? newLocale) {
    locale.value = LocaleExtensions.LocaleFromCode(newLocale);
    if (newLocale != null) {
      Get.updateLocale(locale.value!);
    } else {
      Get.deviceLocale?.let((it) => Get.updateLocale(it));
    }
    // 将语言设置保存到存储中
    _storage.write(AppSettings.languageKey, locale.value?.toLocaleCode());
  }

  setupOpenai() {
    final apikey = apiKeyController.text;
    String? baseUrl =
        openaiBaseUrlController.text.takeIf((p0) => p0.isNotBlank);
    if (baseUrl != null) {
      if (Uri.parse(baseUrl).host.isEmptyOrNull) {
        baseUrl = null;
        Get.snackbar("失败", "Url 格式错误！");
      }
    }

    AppNetwork.get().setupOpenAi(apikey: apikey, baseUrl: baseUrl);
    _storage.write(AppSettings.openaiApiKey, apikey);
    _storage.write(AppSettings.openaiBaseUrl, baseUrl);
    Get.snackbar("成功", "保存成功");
  }
}
