import 'package:flutter/material.dart';
import 'package:aimigo/ui/page/regiester/register_viewmodel.dart';
import 'package:aimigo/ui/page/reset_password/reset_password_controller.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatelessWidget {
  final String username;

  const ResetPasswordPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ResetPasswordController(username));
    return Scaffold(
      appBar: AppBar(
        title: Text("reset_password".tr),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, //宽度尽可能大
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: c.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Text('reset_password'.tr,
                            style: Theme.of(context).textTheme.titleLarge),
                        SizedBox(height: 50),
                        TextFormField(
                          controller: c.usernameController,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: "email".tr,
                            hintText: "email".tr,
                            prefixIcon: Icon(Icons.person),
                            // helperText: '用户名',
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                          ),
                          validator: (v) {
                            return v!.trim().length > 0
                                ? null
                                : "account_cannot_empty".tr;
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Obx(() => TextFormField(
                              controller: c.captchaController,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: "captcha".tr,
                                hintText: "captcha".tr,
                                prefixIcon: Icon(Icons.domain_verification),
                                suffixIcon: IconButton(
                                  onPressed: c.isGettingVerificationCode
                                              .value ||
                                          c.remainingSeconds != 0
                                      ? null
                                      : () =>
                                          c.sendCode(c.usernameController.text),
                                  icon: c.remainingSeconds == 0
                                      ? Icon(Icons.send)
                                      : Text("${c.remainingSeconds.value}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                ),
                                // helperText: '用户名',
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                              ),
                              validator: (v) {
                                return v!.trim().length > 0
                                    ? null
                                    : "verification_code_cannot_empty".tr;
                              },
                            )),
                        SizedBox(
                          height: 16,
                        ),
                        Obx(() => TextFormField(
                              controller: c.passwordController,
                              obscureText: !c.passwordVisible.value,
                              decoration: InputDecoration(
                                labelText: "password".tr,
                                hintText: "your_password".tr,
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    //根据passwordVisible状态显示不同的图标
                                    c.passwordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    //更新状态控制密码显示或隐藏
                                    c.passwordVisible.toggle();
                                  },
                                ),
                                // helperText: '密码',
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                              ),
                              validator: (v) {
                                return v!.trim().length > 0
                                    ? null
                                    : "password_cannot_empty".tr;
                              },
                            )),
                        SizedBox(
                          height: 32,
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: c.isLoading.value
                                  ? null
                                  : () => c.resetPassword(),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50)),
                              child: c.isLoading.value
                                  ? Text("resetting_password".tr)
                                  : Text("reset_password".tr),
                            )),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
