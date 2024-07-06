import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:aimigo/data/network.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

class TTSController extends GetxController {
  Rx<CancelToken?> cancelToken = Rx<CancelToken?>(null);

  final inputController = TextEditingController();

  final outputImages = <ImageResponseData>[].obs;

  final models = <String>["tts-1", "tts-1-hd"];
  final voices = <String>["alloy", "echo", "fable", "onyx", "nova", "shimmer"];
  final response_formats = <String>["mp3", "opus", "aac", "flac"];

  final Rx<String?> model = "".obs;
  final Rx<String?> voice = Rx<String?>(null);
  final Rx<String?> response_format = Rx<String?>(null);
  final speed = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    model(models.first);
    voice(voices.first);
    response_format(response_formats.first);
  }

  Future<void> generations() async {
    try {
      final client = AppNetwork.get().openAiClient;
      if (client == null) {
        Get.snackbar("您未配置 openai ", "请前往“个人主页”->“设置”，配置“Api key”");
        return;
      }

      cancelToken.value = CancelToken();
      final resp = await client.audioApi.speech(
          SpeechRequest(
              model: model.value!,
              input: inputController.text,
              voice: voice.value!,
              responseFormat: response_format.value!,
              speed: speed.value),
          cancelToken: cancelToken.value);

      final player = AudioPlayer();
      final bytes = await readByteStream(resp);
      player.play(BytesSource(bytes));
    } catch (e) {
      Get.snackbar("失败", "出错了");
      print(e);
    } finally {
      cancelToken.value = null;
    }
  }

  void saveNetworkImage(String imageUrl) {}
}
