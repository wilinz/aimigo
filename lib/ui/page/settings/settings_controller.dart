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
  static const themeKey = 'theme';
  static const languageKey = 'language';
  static const openaiBaseUrl = 'openai_base_url';
  static const openaiApiKey = 'openai_api_key';

  var themeMode = ThemeMode.system.obs;
  var locale = LocaleExtensions.LocaleFromCode(null).obs;

  final openaiBaseUrlController = TextEditingController();

  final apiKeyController = TextEditingController();

  SettingsController(this._storage);

  @override
  void onInit() {
    super.onInit();
    // 从存储中加载主题设置和语言设置
    _storage.read<int?>(themeKey)?.let((it) {
      themeMode.value = ThemeMode.values[it];
    });

    LocaleExtensions.LocaleFromCode(_storage.read(languageKey))
        ?.let((it) => locale.value = it);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    // Get.changeThemeMode(option);
    // 将主题设置保存到存储中
    _storage.write(themeKey, mode.index);
  }

  void changeLanguage(String? newLocale) {
    locale.value = LocaleExtensions.LocaleFromCode(newLocale);
    if (newLocale != null) {
      Get.updateLocale(locale.value!);
    } else {
      Get.deviceLocale?.let((it) => Get.updateLocale(it));
    }
    // 将语言设置保存到存储中
    _storage.write(languageKey, locale.value?.toLocaleCode());
  }

  saveOpenaiBaseUrl() {
    _storage.write(openaiBaseUrl, openaiBaseUrlController.text);
  }

  saveApiKey() {
    _storage.write(openaiApiKey, apiKeyController.text);
  }

}
