import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/data/network.dart';
import 'package:get/get.dart';


class ResetPasswordController extends GetxController {
  final String username;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  var isLoading = false.obs;
  GlobalKey formKey = GlobalKey<FormState>();
  var passwordVisible = false.obs;

  var isGettingVerificationCode = false.obs;
  var remainingSeconds = 0.obs;

  ResetPasswordController(this.username);

  @override
  void onInit() {
    super.onInit();
    usernameController.text = username;
  }

  Future<void> resetPassword() async {
    final currentState = formKey.currentState as FormState;
    if (!currentState.validate()) {
      Get.snackbar("出错了", "please_check_the_input".tr);
      return;
    }
    final dio = await AppNetwork.getDio();

    try {
      final resp = await dio.put("/account/password/reset",
          options: Options(responseType: ResponseType.json),
          data: {
            "code": captchaController.text,
            "newPassword": passwordController.text,
            "username": usernameController.text,
          });
      final result = resp.data;
      if (result['code'] == 200) {
        Get.snackbar("出错了", "successful".tr);
        Navigator.pop(Get.context!);
      } else {
        Get.snackbar("出错了","${'failed'.tr}: ${result['msg']}");
      }
    } catch (e) {
      Get.snackbar("出错了", "${'failed'.tr}: ${e}");
      print(e);
    }
  }

  sendCode(String email) async {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar("出错了", "please_enter_your_email_address_first".tr);
      return;
    }

    isGettingVerificationCode.value = true;

    final dio = await AppNetwork.getDio();
    final resp = await dio.post("/account/verify",
        data: {"codeType": "reset_password", "graphicCode": "", "phoneOrEmail": email});
    final respBody = resp.data;
    if (respBody['code'] == 200) {
      Get.snackbar("出错了", "verification_code_sent_successfully".tr);
      // 启动倒计时
      const countdownDuration = 60; // 倒计时时长

      remainingSeconds.value = countdownDuration;
      Timer.periodic(Duration(seconds: 1), (timer) {
        remainingSeconds.value = countdownDuration - timer.tick;

        if (remainingSeconds.value == 0) {
          timer.cancel();
        }
      });
    } else {
      Get.snackbar("出错了","${'verification_code_sent_failed'.tr}：${respBody['msg']}");
    }

    isGettingVerificationCode.value = false;
  }
}