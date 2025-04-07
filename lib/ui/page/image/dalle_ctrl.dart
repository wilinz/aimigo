import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aimigo/data/network.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

class DallEController extends GetxController {
  Rx<CancelToken?> cancelToken = Rx<CancelToken?>(null);

  final promptController = TextEditingController();

  final outputImages = <ImageResponseData>[].obs;

  final models = <String>["dall-e-3", "dall-e-2"];
  final sizesDallE2 = <String>["256x256", "512x512", "1024x1024"];
  final sizesDallE3 = <String>["1024x1024", "1792x1024", "1024x1792"];
  final sizes = <String>[].obs;
  final styles = <String>["vivid", "natural"];
  final qualitys = <String?>[null, "hd"];

  final Rx<String?> model = "".obs;
  final number = 1.obs;
  final Rx<String?> quality = Rx<String?>(null);
  final Rx<String?> size = Rx<String?>(null);
  final Rx<String?> style = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    model.listen((model) {
      if (model == "dall-e-3") {
        sizes(sizesDallE3);
      } else {
        sizes(sizesDallE2);
      }
      size(sizes.first);
    });
    model(models.first);
    quality(qualitys.first);
    style(styles.first);
  }

  Future<void> generations() async {
    try {
      final client = AppNetwork.get().openAiClient;
      if (client == null) {
        Get.snackbar("您未配置 openai ", "请前往“个人主页”->“设置”，配置“Api key”");
        return;
      }

      cancelToken.value = CancelToken();
      final resp = await client.imageApi.generations(
          ImageGenerationRequest(
            prompt: promptController.text,
            model: model.value,
            n: number.value,
            quality: quality.value,
            responseFormat: "b64_json",
            size: size.value,
            style: style.value,
          ),
          cancelToken: cancelToken.value);
      outputImages.value = resp.data;
    } catch (e) {
      Get.snackbar("失败", "出错了");
      print(e);
    } finally {
      cancelToken.value = null;
    }
  }

  Future<void> saveNetworkImage(String imageUrl) async {
    if (GetPlatform.isDesktop) {
      Get.snackbar("失败", "暂不支持非移动端");
      return;
    }
    bool isGranted;
    if (Platform.isAndroid) {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      isGranted = await (sdkInt > 33 ? Permission.photos : Permission.storage)
          .request()
          .isGranted;
    } else {
      isGranted = await Permission.photosAddOnly.request().isGranted;
    }

    if (isGranted) {
      String picturesPath =
          DateTime.timestamp().millisecondsSinceEpoch.toString() + ".jpg";
      debugPrint(picturesPath);
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(base64Decode(imageUrl)),
        quality: 100,
        fileName: picturesPath,
        androidRelativePath: "Pictures/Aimigo",
        skipIfExists: false,
      );
      debugPrint(result.toString());
      Get.snackbar("成功", "保存成功");
    } else {
      Get.snackbar("失败", "请允许权限");
    }
  }
}
