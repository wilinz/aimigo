import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:aimigo/data/network.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

class TTSController extends GetxController {
  Rx<CancelToken?> cancelToken = Rx<CancelToken?>(null);

  final inputController = TextEditingController();
  final instructionsController = TextEditingController();

  final Rx<List<int>?> outputAudio = Rx<List<int>?>(null);

  final models = <String>["gpt-4o-mini-tts", "tts-1", "tts-1-hd"];
  final voices = <String>[
    'alloy',
    'ash',
    'ballad',
    'coral',
    'echo',
    'fable',
    'onyx',
    'nova',
    'sage',
    'shimmer',
    'verse'
  ];
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
              instructions: instructionsController.text,
              responseFormat: response_format.value!,
              speed: speed.value),
          cancelToken: cancelToken.value,
      );

      final bytes = await readByteStream(resp);
      outputAudio.value = bytes;
    } catch (e) {
      Get.snackbar("失败", "出错了");
      print(e);
    } finally {
      cancelToken.value = null;
    }
  }

  // Save audio using file_saver
  void saveAudio(List<int> audioBytes) async {
    try {
      final dir = await FileSaver.instance.saveFile(
        name:
            'audio-${DateFormat("yyyy-MM-dd-HH_mm_ss_SSS").format(DateTime.now())}.mp3',
        bytes: Uint8List.fromList(audioBytes),
        mimeType: MimeType.mp3,
      );
      Get.snackbar("保存成功", "音频已保存到：${dir}");
    } catch (e) {
      print(e);
      Get.snackbar("保存失败", "音频保存失败");
    }
  }
}
