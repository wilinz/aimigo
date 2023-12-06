
import 'package:get/get.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

class MyMarkdownController extends GetxController {
  late ChatMessage message;
  var isSourceMode = false.obs;

  MyMarkdownController({required this.message});

  Future<void> textToSpeech() async {

  }
}