import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/check_update.dart';
import 'package:aimigo/package_info.dart';
import 'package:aimigo/ui/page/main/profile/profile_vm.dart';
import 'package:aimigo/ui/page/settings/settings_page.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../../../route.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        title: Text("profile".tr),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('settings'.tr),
                value: 'settings',
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                // 导航到设置页面
                Get.toNamed(AppRoute.settingsPage);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoute.loginPage, arguments: true);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Image(
                            image: AssetImage("assets/images/logo.png"),
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder(
                                  stream: c.getActiveUserStream(),
                                  builder: (context, item) {
                                    final user = item.data;
                                    return Text(
                                      user == null ? "请登录" : user.username,
                                      style: Get.theme.textTheme.titleMedium,
                                    );
                                  }),
                              // SizedBox(height: 4),
                              // Text("info"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              ListTile(
                onTap: () {
                  logout(c);
                },
                leading: Icon(Icons.logout_outlined),
                title: Text("退出登录"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(Icons.person_outline),
                title: Text("关于"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                onTap: () async {
                  if (kIsWeb) return;
                  await c.checkUpdate();
                  final appVersion = c.appVersion.value;
                  if (appVersion != null &&
                      appVersion.isHasNewVersion(packageInfo)) {
                    showDialog(
                        context: Get.context!,
                        barrierDismissible: !appVersion.isForce,
                        builder: (context) =>
                            UpdateDialog(appVersion: appVersion));
                  } else {
                    Get.snackbar("版本信息", "已经最新版本");
                  }
                },
                leading: Icon(Icons.info_outline),
                title: Obx(() {
                  final appVersion = c.appVersion.value;
                  if (appVersion != null &&
                      appVersion.isHasNewVersion(packageInfo)) {
                    return Text(
                        "版本：${packageInfo.version} -> ${appVersion.versionName}");
                  }
                  return Text("版本：${packageInfo.version}");
                }),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                onTap: () {
                  Get.toNamed(AppRoute.sponsorPage);
                },
                leading: Icon(Icons.thumb_up_alt_outlined),
                title: Text("给开发者点赞！"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildItem({required String text, required VoidCallback? onPressed}) {
    return Expanded(
      flex: 1,
      child: SizedBox(
        height: 50,
        child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            onPressed: onPressed,
            child: Text(text)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void logout(ProfileController c) {
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: Text("确定"),
            content: Text("确定退出登录？"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              TextButton(
                  onPressed: () async {
                    await c.logout();
                    Navigator.pop(context);
                  },
                  child: Text("确定"))
            ],
          );
        });
  }
}
