import 'package:aimigo/ui/widget/context_menu_region.dart';
import 'package:aimigo/ui/widget/slider_tile.dart';
import 'package:aimigo/util/base64_data_url_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tts_ctrl.dart';

class TTSPage extends StatelessWidget {
  const TTSPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TTSController());
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
                controller: c.inputController,
                autofocus: false,
                maxLines: 10,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: "请输入文本",
                  hintText: "请输入文本".tr,
                  prefixIcon: Icon(Icons.draw_outlined),
                  // helperText: '用户名',
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
                    title: Text('速度: ${c.speed}'),
                    slider: Slider(
                      value: c.speed.toDouble(),
                      onChanged: (newValue) {
                        c.speed(newValue);
                      },
                      min: 0.25,
                      max: 4.0,
                      divisions: null,
                      label: '速度: ${c.speed}',
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
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // padding: EdgeInsets.all(16.0),
                    itemCount: c.outputImages.length,
                    separatorBuilder: (BuildContext context, int index) {
                      // 返回用于分隔列表项的小部件
                      return SizedBox(height: 16);
                    },
                    itemBuilder: (context, index) {
                      final image = c.outputImages[index];
                      return Column(
                        children: [
                          Text("revised prompt: "),
                          SelectableText(image.revisedPrompt),
                          SizedBox(height: 8),
                          ContextMenuRegion(
                            contextMenuBuilder:
                                (BuildContext context, Offset offset) =>
                                    _buildContent(c, offset, image.b64Json),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image(
                                    image: Base64UrlImage(
                                        "data:image/png;base64," +
                                            image.b64Json))),
                          ),
                        ],
                      );
                    },
                  )),
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
