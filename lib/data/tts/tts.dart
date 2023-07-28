import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'dart:io';

extension _Uint8ListExtension on Uint8List {
  int indexOfSubList(List list, {int start = 0}) {
    if (list.isEmpty) {
      return -1;
    }
    if (start < 0) {
      start = 0;
    }
    for (var i = start; i < this.length - list.length + 1; i++) {
      if (this[i] == list[0]) {
        var match = true;
        for (var j = 1; j < list.length; j++) {
          if (this[i + j] != list[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          return i;
        }
      }
    }
    return -1;
  }
}

String _getGuid() => Uuid().v4().toString().replaceAll("-", "");

String _getISOTime(DateTime date) {
  final formatter = DateFormat('EEE MMM dd yyyy HH:mm:ss \'GMT\'');
  final formattedDate = formatter.format(date.toUtc());
  return formattedDate;
}

String _numToString(int num) {
  return num >= 0 ? '+$num' : '$num';
}

String _buildMessage(String header, String body) =>
    (header + "\n\n" + body).replaceAll("\n", "\r\n");

Stream<Uint8List> tts(String text,
    {required String language,
    required String voiceName,
    int pitch = 0,
    int rate = 0}) {
  if (text.isEmpty) {
    throw Exception('Please enter text');
  }

  final audioConfig = _buildMessage(
      """X-Timestamp:${_getISOTime(DateTime.now())}
Content-Type:application/json; charset=utf-8
Path:speech.config""",
      jsonEncode({
        "context": {
          "synthesis": {
            "audio": {
              "metadataoptions": {
                "sentenceBoundaryEnabled": "false",
                "wordBoundaryEnabled": "true"
              },
              "outputFormat": "audio-24khz-48kbitrate-mono-mp3"
            }
          }
        }
      }));

  final ssmlText = _buildMessage("""X-RequestId:${_getGuid()}
Content-Type:application/ssml+xml
X-Timestamp:${_getISOTime(DateTime.now())}
Path:ssml""",
      """<speak xmlns:mstts='https://www.w3.org/2001/mstts' version='1.0'
    xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='${language}'>
    <voice name='${voiceName}'>
        <prosody pitch='${_numToString(pitch)}Hz' rate='${_numToString(rate)}%' volume='+0%'>${text}</prosody>
    </voice>
</speak>""");

  final webSocketUrl =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4&ConnectionId=' +
          _getGuid();

  final channel = IOWebSocketChannel.connect(Uri.parse(webSocketUrl), headers: {
    "Accept-Encoding": "gzip, deflate, br",
    "Origin": "chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.66 Safari/537.36 Edg/103.0.1264.44"
  });

  final streamController = StreamController<Uint8List>();
  final stream = streamController.stream;
  channel.sink.add(audioConfig);
  channel.sink.add(ssmlText);
  final audioSeparator = utf8.encode("Path:audio");

  channel.stream.listen((data) async {
    if (data is Uint8List) {
      Uint8List view = data;
      final index = view.indexOfSubList(audioSeparator);
      final dataBytes = view.sublist(index + 12);
      streamController.add(dataBytes);
    } else if (data is String) {
      if (data.contains("Path:turn.end")) {
        streamController.close();
      }
    }
  }, onError: (error) {
    streamController.addError(error);
  }, onDone: () {});

  return stream;
}
