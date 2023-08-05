import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/ui/page/settings/settings_page.dart';
import 'package:get/get.dart';
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
                              Text(("first name") + (" second name")),
                              SizedBox(height: 4),
                              Text("info"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          buildItem(
                              text: "Ai聊天",
                              onPressed: () {
                                Get.toNamed(AppRoute.chatPage);
                              }),
                          buildItem(
                              text: "Ai绘画",
                              onPressed: () {
                                Get.snackbar("施工中", "正在施工中");
                                // Get.to(AppRoute.chatPage);
                              }),
                        ]),
                        Row(
                          children: [
                            buildItem(
                                text: "Ai翻译",
                                onPressed: () {
                                  Get.snackbar("施工中", "正在施工中");
                                  // Get.to(AppRoute.chatPage);
                                }),
                            buildItem(
                                text: "Ai语音",
                                onPressed: () {
                                  Get.snackbar("施工中", "正在施工中");
                                  // Get.to(AppRoute.chatPage);
                                })
                          ],
                        )
                      ],
                    ),
                  ),
                ),
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
}
