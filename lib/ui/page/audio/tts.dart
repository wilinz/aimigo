import 'dart:typed_data';

import 'package:aimigo/ui/widget/slider_tile.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import the file_saver package

import 'tts_ctrl.dart';

class TTSPage extends StatelessWidget {
  const TTSPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TTSController());
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Scaffold(
          appBar: AppBar(
            title: Text("TTS"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: c.inputController,
                    autofocus: false,
                    maxLines: 10,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: "请输入文本",
                      hintText: "请输入文本".tr,
                      prefixIcon: Icon(Icons.draw_outlined),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    validator: (v) {
                      return v!.trim().length > 0 ? null : "输入为空";
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: c.instructionsController,
                    autofocus: false,
                    maxLines: 10,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: "附加指令",
                      hintText: "使用附加指令控制生成的音频的声音".tr,
                      prefixIcon: Icon(Icons.draw_outlined),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                    ),
                    validator: (v) {
                      return v!.trim().length > 0 ? null : "输入为空";
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16,16,16,0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('模型:'),
                        SizedBox(width: 8),
                        Obx(() => DropdownButton<String>(
                          value: c.model.value,
                          onChanged: (String? newValue) {
                            c.model.value = newValue!;
                          },
                          items: c.models.map((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                        ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('发音人:'),
                        SizedBox(width: 8),
                        Obx(() => DropdownButton<String>(
                          value: c.voice.value,
                          onChanged: (String? newValue) {
                            c.voice.value = newValue;
                          },
                          items: c.voices.map((String? voice) {
                            return DropdownMenuItem<String>(
                              value: voice,
                              child: Text(voice ?? "默认"),
                            );
                          }).toList(),
                        ))
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Obx(() => SliderTile(
                    title: Text('速度: ${c.speed.toStringAsFixed(2)}'),
                    slider: Slider(
                      value: c.speed.toDouble(),
                      onChanged: (newValue) {
                        c.speed(newValue);
                      },
                      min: 0.25,
                      max: 4.0,
                      divisions: null,
                      label: '速度: ${c.speed.toStringAsFixed(2)}',
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                        onPressed: c.cancelToken.value == null
                            ? c.generations
                            : () {
                          c.cancelToken.value?.cancel();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (c.cancelToken.value != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.sync),
                              ),
                            Text(c.cancelToken.value == null ? "生成音频" : "取消生成"),
                          ],
                        ),
                      )),
                    ),
                  ),
                  Obx(() => Column(
                    children: [
                      if (c.outputAudio.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final player = AudioPlayer();
                                final bytes = Uint8List.fromList(c.outputAudio.value!);
                                player.play(BytesSource(bytes, mimeType: "audio/mp3"));
                              },
                              child: Text('播放音频'),
                            ),
                          ),
                        ),
                      if (c.outputAudio.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Save the audio file
                                c.saveAudio(c.outputAudio.value!);
                              },
                              child: Text('保存音频'),
                            ),
                          ),
                        ),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
