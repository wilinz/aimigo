import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/get_storage.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController _c = Get.put(SettingsController(getStorage));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('theme'.tr),
            trailing: Obx(
              () => DropdownButton(
                padding: EdgeInsets.only(left: 12, right: 12),
                value: _c.themeMode.value,
                focusColor: Colors.transparent,
                // 设置焦点颜色为透明
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('follow_system'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('light'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('dark'.tr),
                  ),
                ],
                onChanged: (value) => _c.setThemeMode(value!),
              ),
            ),
          ),
          ListTile(
            title: Text('language'.tr),
            trailing: DropdownButton(
              padding: EdgeInsets.only(left: 12, right: 12),
              value: _c.locale.value?.toLocaleCode(),
              focusColor: Colors.transparent,
              // 设置焦点颜色为透明
              items: <DropdownMenuItem<String?>>[
                DropdownMenuItem(
                  value: null,
                  child: Text('follow_system'.tr),
                ),
                DropdownMenuItem(
                  value: "en_US",
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: "zh_CN",
                  child: Text('中文'),
                ),
              ],
              onChanged: (value) => _c.changeLanguage(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              children: [
                Obx(() => TextFormField(
                      controller: _c.apiKeyController,
                      autofocus: false,
                      obscureText: !_c.apikeyVisible.value,
                      maxLines: 1,
                      minLines: 1,
                      decoration: InputDecoration(
                        labelText: "接口密钥（api key）",
                        hintText: "请输入接口密钥（api key）",
                        suffixIcon: IconButton(
                          icon: Icon(
                            //根据passwordVisible状态显示不同的图标
                            _c.apikeyVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            //更新状态控制密码显示或隐藏
                            _c.apikeyVisible.toggle();
                          },
                        ),
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                      ),
                    )),
                SizedBox(height: 16),
                TextFormField(
                  controller: _c.openaiBaseUrlController,
                  autofocus: false,
                  maxLines: 10,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: "（可选）基本网址（base url）",
                    hintText: "请输入基本网址（base url）",
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _c.setupOpenai, child: Text("保存 OpenAi 配置")))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
