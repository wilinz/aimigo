import 'package:aimigo/ui/page/sponsor/sponsor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    SponsorController c = Get.put(SponsorController());
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Scaffold(
          appBar: AppBar(
            title: Text("给开发者点赞"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(() => c.qrCodeText.isNotEmpty
                    ? QrImageView(
                        data: c.qrCodeText.value,
                        version: QrVersions.auto,
                        size: 200.0,
                        embeddedImage: Svg("assets/images/alipay.svg"),
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Get.isDarkMode ? Colors.white : Colors.black,
                        ),
                      )
                    : Container()),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                    width: double.infinity,
                    child:
                        ElevatedButton(onPressed: c.pay, child: Text("👍只收一元，多给不收"))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
