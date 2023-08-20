import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aimigo/data/get_storage.dart';
import 'package:aimigo/data/model/app/app_version/app_version.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatefulWidget {
  final AppVersion appVersion;

  UpdateDialog({
    required this.appVersion,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final GetStorage _storage = getStorage;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat("yyyy-MM-dd HH:mm:ss", Intl.systemLocale);

    bool isHideVersion() {
      final int isHideVersion = _storage.read('isHideVersion') ?? -1;
      return isHideVersion == widget.appVersion.versionCode;
    }

    void setHideVersion(bool v) {
       setState(() {
         _storage.write('isHideVersion', v ? widget.appVersion.versionCode : -1);
       });
    }

    return AlertDialog(
      title: Text('新版本'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('版本: ${widget.appVersion.versionName}'),
          Text(format.format(
              DateTime.fromMillisecondsSinceEpoch(widget.appVersion.createdAt))),
          // markdown todo
          Text('更新日志: ${widget.appVersion.changelog}'),
          if (widget.appVersion.canHide && !widget.appVersion.isForce)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListTile(
                onTap: () {
                  setHideVersion(!isHideVersion());
                },
                leading: Checkbox(
                  value: isHideVersion(),
                  onChanged: (v) {
                    setHideVersion(v!);
                  },
                ),
                title: Text("不再提示"),
              ),
            ),
        ],
      ),
      actions: [
        if (!widget.appVersion.isForce)
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('取消'),
          ),
        if (widget.appVersion.isForce)
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: Text('退出'),
          ),
        TextButton(
          onPressed: () {
            launchUrl(Uri.parse(widget.appVersion.downloadUrl),
                mode: LaunchMode.externalApplication);
            Get.back();
          },
          child: Text('更新'),
        ),
      ],
    );
  }
}
