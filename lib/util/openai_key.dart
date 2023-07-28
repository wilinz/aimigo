import 'dart:math';

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

String generateOpenAiKey(int length) {
  final random = Random();
  final key = List.generate(length, (_) => charset[random.nextInt(charset.length)]);
  return "sk-" + key.join('');
}
