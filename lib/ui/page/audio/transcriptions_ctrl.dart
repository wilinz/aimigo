import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:aimigo/data/network.dart';
import 'package:chunked_stream/chunked_stream.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kt_dart/kt.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as path;

class TranscriptionsController extends GetxController {
  Rx<CancelToken?> cancelToken = Rx<CancelToken?>(null);
  Rx<CancelToken?> cancelToken2 = Rx<CancelToken?>(null);

  final promptController = TextEditingController();
  final languageController = TextEditingController();

  AudioRecorder? record;

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

  final models = <String>['gpt-4o-transcribe', 'gpt-4o-mini-transcribe', 'whisper-1'];
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

  final isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
    model(models.first);
    response_format(response_formats[1]);
  }

  Future<void> saveOutputToFile() async {
    try {
      if (output.value.isNotEmpty) {
        final fileName = file.value != null
            ? 'transcriptions-' + path.basenameWithoutExtension(file.value!.path)
            : 'transcriptions-${DateTime.timestamp().millisecondsSinceEpoch}.txt'; // You can change the file name and extension as needed
        final data = utf8.encode(output.value);

        final savePath = await FileSaver.instance.saveFile(
            bytes: data,
            mimeType: MimeType.text,
            ext: response_format.value ?? 'json',
            name: fileName);
        Get.snackbar("Success", "Output saved to file: $savePath");
      } else {
        Get.snackbar("Error", "Output is empty, cannot save to file");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save output to file");
      print(e);
    }
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

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions);

    if (result != null) {
      file.value = File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  int startRecordingTime = 0;

  Future<void> startRecording() async {
    isRecording(true);
    startRecordingTime = DateTime.timestamp().millisecondsSinceEpoch;
    await Permission.microphone.onDeniedCallback(() {
      isRecording(false);
    }).onGrantedCallback(() async {
      record?.stop();
      record?.dispose();
      record = AudioRecorder();
      // Start recording to file
      final dir = await getApplicationSupportDirectory();
      final path = join(dir.path, "speech_recognition",
          DateTime.timestamp().millisecondsSinceEpoch.toString() + ".wav");
      final f = File(path);
      await f.create(recursive: true);
      await record!
          .start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
    }).request();
  }

  Future<void> stopRecording() async {
    try {
      isRecording(false);
      final stopRecordingTime = DateTime.timestamp().millisecondsSinceEpoch;
      if (stopRecordingTime - startRecordingTime < 300) {
        Get.snackbar("失败", "录音时间短");
        final oldRecord = record;
        record = null;
        Future.delayed(Duration(milliseconds: 500), () async {
          try {
            final p = await oldRecord?.stop();
            if (p != null) File(p).delete();
          } catch (e) {
            print(e);
          }
          oldRecord?.dispose();
        });
        throw Exception("The recording time is short");
      }
      final path = await record?.stop();
      if (path == null) {
        Get.snackbar("失败", "未录音");
        throw Exception("path is null");
      }
      Get.snackbar("成功", "已经录音，并存入文件，您可以点击识别或翻译了");
      file.value = File(path);
    } catch (e) {
      print(e);
    } finally {
      record?.dispose();
      record = null;
    }
  }
}
