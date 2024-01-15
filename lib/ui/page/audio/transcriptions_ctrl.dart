import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:aimigo/data/network.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:kt_dart/kt.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';
import 'package:dio/dio.dart' as dio;

class TranscriptionsController extends GetxController {
  Rx<CancelToken?> cancelToken = Rx<CancelToken?>(null);
  Rx<CancelToken?> cancelToken2 = Rx<CancelToken?>(null);

  final promptController = TextEditingController();
  final languageController = TextEditingController();

  final allowedExtensions = [
    'flac',
    'm4a',
    'mp3',
    'mp4',
    'mpeg',
    'mpga',
    'oga',
    'ogg',
    'wav',
    'webm'
  ];

  final output = "".obs;

  final models = <String>["whisper-1"];
  final response_formats = <String>[
    "json",
    "text",
    "srt",
    "verbose_json",
    "vtt"
  ];

  /// 'flac', 'm4a', 'mp3', 'mp4', 'mpeg', 'mpga', 'oga', 'ogg', 'wav', 'webm'
  final Rx<File?> file = Rx(null);
  final model = "".obs;
  final Rx<String?> response_format = Rx(null);
  final RxDouble temperature = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    model(models.first);
    response_format(response_formats.first);
  }

  Future<void> transcriptions() async {
    try {
      final client = AppNetwork.get().openAiClient;
      if (client == null) {
        Get.snackbar("您未配置 openai ", "请前往“个人主页”->“设置”，配置“Api key”");
        return;
      }

      cancelToken.value = CancelToken();
      final dio.MultipartFile mf = (await dio.MultipartFile.fromFile(
          file.value!.path,
          filename: "audio.mp3"));

      final resp = await client.audioApi.transcriptions<String>(
          SpeechRecognitionRequest(
            model: model.value,
            file: mf,
            language: languageController.text.takeIf((it) => it.isNotBlank),
            prompt: promptController.text.takeIf((it) => it.isNotBlank),
            responseFormat: response_format.value,
            temperature: temperature.value,
          ),
          options: Options(responseType: ResponseType.plain),
          cancelToken: cancelToken.value);

      output(resp);
    } catch (e) {
      Get.snackbar("失败", "出错了");
      print(e);
    } finally {
      cancelToken.value = null;
    }
  }

  Future<void> translate() async {
    try {
      final client = AppNetwork.get().openAiClient;
      if (client == null) {
        Get.snackbar("您未配置 openai ", "请前往“个人主页”->“设置”，配置“Api key”");
        return;
      }

      cancelToken2.value = CancelToken();
      final dio.MultipartFile mf = (await dio.MultipartFile.fromFile(
          file.value!.path,
          filename: "audio.mp3"));

      final resp = await client.audioApi.translations<String>(
          SpeechRecognitionRequest(
            model: model.value,
            file: mf,
            prompt: promptController.text.takeIf((it) => it.isNotBlank),
            responseFormat: response_format.value,
            temperature: temperature.value,
          ),
          options: Options(responseType: ResponseType.plain),
          cancelToken: cancelToken2.value);

      output(resp);
    } catch (e) {
      Get.snackbar("失败", "出错了");
      print(e);
    } finally {
      cancelToken2.value = null;
    }
  }

  void saveNetworkImage(String imageUrl) {}

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions);

    if (result != null) {
      file.value = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }
}
