import 'package:aimigo/ui/page/audio/transcriptions_ctrl.dart';
import 'package:aimigo/ui/widget/context_menu_region.dart';
import 'package:aimigo/ui/widget/slider_tile.dart';
import 'package:aimigo/util/base64_data_url_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tts_ctrl.dart';

class TranscriptionsPage extends StatelessWidget {
  const TranscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TranscriptionsController());
    return Scaffold(
      appBar: AppBar(
        title: Text("TTS"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: c.promptController,
                autofocus: false,
                maxLines: 10,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: "提示（可选）",
                  hintText: "提示（可选）".tr,
                  prefixIcon: Icon(Icons.draw_outlined),
                  // helperText: '用户名',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                validator: (v) {
                  return v!.trim().length > 0 ? null : "输入为空";
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: c.promptController,
                autofocus: false,
                maxLines: 10,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: "语言代码（可选）",
                  hintText: "语言代码（可选）".tr,
                  prefixIcon: Icon(Icons.draw_outlined),
                  // helperText: '用户名',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                validator: (v) {
                  return v!.trim().length > 0 ? null : "输入为空";
                },
              ),
              SizedBox(height: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: c.pickFile,
                      child: Text("选择音频文件: 支持的格式：${c.allowedExtensions.join(", ")}")),
                  if (c.file.value != null)
                    Obx(() => Text(
                          c.file.value?.path ?? "",
                        ))
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                    Text('输出格式:'),
                    SizedBox(width: 8),
                    Obx(() => DropdownButton<String>(
                          value: c.response_format.value,
                          onChanged: (String? newValue) {
                            c.response_format.value = newValue;
                          },
                          items: c.response_formats.map((String? voice) {
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
                    title: Text('temperature: ${c.temperature}'),
                    slider: Slider(
                      value: c.temperature.toDouble(),
                      onChanged: (newValue) {
                        c.temperature(newValue);
                      },
                      min: 0,
                      max: 1,
                      divisions: null,
                      label: 'temperature: ${c.temperature}',
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: c.cancelToken.value == null
                            ? c.transcriptions
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
                            Text(c.cancelToken.value == null ? "识别" : "取消识别"),
                          ],
                        ),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: c.cancelToken2.value == null
                            ? c.translate
                            : () {
                                c.cancelToken2.value?.cancel();
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (c.cancelToken2.value != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.sync),
                              ),
                            Text(c.cancelToken2.value == null ? "翻译" : "取消翻译"),
                          ],
                        ),
                      )),
                ),
              ),
              Obx(() => SelectableText(c.output.value))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TTSController c, Offset offset, String imageUrl) {
    return AdaptiveTextSelectionToolbar.buttonItems(
        anchors: TextSelectionToolbarAnchors(
          primaryAnchor: offset,
        ),
        buttonItems: ['保存图片']
            .map((label) => ContextMenuButtonItem(
                  onPressed: () {
                    ContextMenuController.removeAny();
                    c.saveNetworkImage(imageUrl);
                  },
                  label: label,
                ))
            .toList());
  }
}
