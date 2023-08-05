import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_template/data/network.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final images = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
  ].obs;

  i() async {
    // OpenAI.instance.image.create(prompt: prompt)
  }
}

