import 'dart:convert';
import 'dart:typed_data';

import 'package:aimigo/data/network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

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
    final result = await ImageGallerySaver.saveImage(base64Decode(imageUrl),
        quality: 60, name: "hello");
    // {filePath: content://media/external/images/media/1000033022, errorMessage: null, isSuccess: true}
    if (result['isSuccess'] == true) {
      Get.snackbar("成功", "保存成功");
    } else {
      Get.snackbar("失败", result['errorMessage']);
    }
  }
}
