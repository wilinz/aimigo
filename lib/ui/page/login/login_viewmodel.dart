import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/util/md5.dart';
import 'package:dio/src/response.dart' as dio_response;
import 'package:get/get.dart';
import 'package:kt_dart/kt.dart';

import '../../../data/model/account/login_response/login_response.dart';
import '../../../data/model/user/user.dart';
import '../../../data/repository/user.dart';
import '../../route.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  final TextEditingController usernameController =
      TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  GlobalKey formKey = GlobalKey<FormState>();
  var passwordVisible = false.obs;

  var isVerificationCodeLogin = false.obs;
  final captchaController = TextEditingController();
  var isGettingVerificationCode = false.obs;
  var remainingSeconds = 0.obs;

  Future<void> login(
      FormState currentState, String username, String password) async {
    if (!currentState.validate()) {
      Get.snackbar("出错了", "请检查输入");
      return;
    }
    final dio = await AppNetwork.getDio();

    try {
      dio_response.Response<dynamic>? resp;
      if (isVerificationCodeLogin.value) {
        resp = await dio.post("/account/login_with_code",
            options: Options(responseType: ResponseType.json),
            data: {"username": username, "code": captchaController.text});
      } else {
        resp = await dio.post("/account/login",
            options: Options(responseType: ResponseType.json),
            data: {"username": username, "password": sha256Text(password)});
      }

      final loginResult = LoginResponse.fromJson(resp.data);
      if (loginResult.code == 200) {
        Get.snackbar("成功", "登录成功");
        Get.offNamed(AppRoute.mainPage);
        UserRepository.getInstance().login(username);
      } else {
        Get.snackbar("出错了", "登录失败: ${loginResult.msg}");
      }
    } catch (e) {
      Get.snackbar("出错了", "登录失败: ${e}");
      print(e);
    }
  }

  Future<User?> getRecentUser() async =>
      UserRepository.getInstance().getRecentUser();

  @override
  Future<void> onInit() async {
    super.onInit();
    final recentUser = await getRecentUser();
    recentUser?.let((it) {
      usernameController.text = it.username;
      passwordController.text = it.password;
    });
  }

  sendCode(String email) async {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar("出错了", "please_enter_your_email_address_first".tr);
      return;
    }

    isGettingVerificationCode.value = true;

    final dio = await AppNetwork.getDio();
    final resp = await dio.post("/account/verify",
        data: {"codeType": "login", "graphicCode": "", "phoneOrEmail": email});
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
