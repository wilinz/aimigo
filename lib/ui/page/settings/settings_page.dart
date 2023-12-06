import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/get_storage.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController _c =
      Get.put(SettingsController(getStorage));

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
          TextFormField(
            controller: _c.apiKeyController,
            autofocus: false,
            maxLines: 10,
            minLines: 1,
            decoration: InputDecoration(
              labelText: "Api Key",
              hintText: "请输入Api Key",
              suffixIcon: IconButton(
                  onPressed: _c.saveApiKey(),
                  icon: Icon(Icons.done)),
              border: const OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(16))),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _c.openaiBaseUrlController,
            autofocus: false,
            maxLines: 10,
            minLines: 1,
            decoration: InputDecoration(
              labelText: "消息",
              hintText: "请输入消息",
              suffixIcon: IconButton(
                  onPressed: _c.saveOpenaiBaseUrl() ,
                  icon: Icon(Icons.send)),
              border: const OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(16))),
            ),
          )
        ],
      ),
    );
  }
}
