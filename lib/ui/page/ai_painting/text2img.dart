import 'package:aimigo/ui/widget/context_menu_region.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/data/model/stablediffusion/sdcommunity/model_response/model_response.dart';
import 'package:aimigo/ui/page/ai_painting/text2img_controller.dart';
import 'package:get/get.dart';

class Text2ImgPage extends StatelessWidget {
  final SDModel model;
  late Text2ImgPageController c;

  Text2ImgPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    c = Get.put(Text2ImgPageController(model: model));
    return Scaffold(
      appBar: AppBar(
        title: Text('Ai绘图'),
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                        controller: c.promptController,
                        decoration: InputDecoration(
                          labelText: '描述',
                        ),
                        maxLines: 10,
                        minLines: 1),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: c.negativePromptController,
                      decoration: InputDecoration(
                        labelText: '负面描述(可选)',
                      ),
                      maxLines: 10,
                      minLines: 1,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text("是否增强描述"),
                onTap: () {
                  c.isEnhancePrompt.toggle();
                },
                trailing: Switch(
                    value: c.isEnhancePrompt.value,
                    onChanged: (it) {
                      c.isEnhancePrompt.value = it;
                    }),
              ),
              ListTile(
                title: Text("使用英文描述"),
                onTap: () {
                  c.multiLingual.toggle();
                },
                trailing: Switch(
                    value: c.multiLingual.isFalse,
                    onChanged: (it) {
                      c.multiLingual(!it);
                    }),
              ),
              SizedBox(height: 16),
              SliderTile(
                title: Text('宽度: ${c.width} px'),
                slider: Slider(
                  value: c.width.toDouble(),
                  onChanged: (newValue) {
                    c.width.value = newValue.toInt();
                  },
                  min: 0,
                  max: 1024,
                  divisions: 1024 ~/ 8,
                  label: '宽度: ${c.width} px',
                ),
              ),
              SliderTile(
                title: Text('高度 ${c.height} px'),
                slider: Slider(
                  value: c.height.toDouble(),
                  onChanged: (newValue) {
                    c.height.value = newValue.toInt();
                  },
                  min: 0,
                  max: 1024,
                  divisions: 1024 ~/ 8,
                  label: '高度: ${c.height} px',
                ),
              ),
              SliderTile(
                title: Text('图像数量: ${c.number}'),
                slider: Slider(
                  value: c.number.toDouble(),
                  onChanged: (newValue) {
                    c.number(newValue.toInt());
                  },
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: '图像数量: ${c.number}',
                ),
              ),
              ListTile(
                  onTap: () {
                    c.isShowAdvancedOptions.toggle();
                  },
                  title: Text("高级选项"),
                  trailing: Icon(c.isShowAdvancedOptions.isFalse
                      ? Icons.expand_more
                      : Icons.expand_less)),
              Visibility(
                visible: c.isShowAdvancedOptions.value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            TextField(
                              controller: c.seedController,
                              decoration: InputDecoration(
                                labelText: 'seed(可选)',
                              ),
                              keyboardType: TextInputType.number,
                              maxLines: 1,
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                              controller: c.loraModel,
                              decoration: InputDecoration(
                                labelText: 'loraModel(可选)',
                              ),
                              maxLines: 5,
                              minLines: 1,
                            ),
                            SizedBox(height: 16.0),
                            TextField(
                                controller: c.loraStrength,
                                decoration: InputDecoration(
                                  labelText: 'loraStrength(可选)',
                                ),
                                maxLines: 5,
                                minLines: 1),
                            SizedBox(height: 16.0),
                            TextField(
                              controller: c.embeddingsModel,
                              decoration: InputDecoration(
                                labelText: '嵌入模型(可选)',
                              ),
                              maxLines: 5,
                              minLines: 1,
                            ),
                          ],
                        ),
                      ),
                      // Add more option items here
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('调度器:'),
                            DropdownButton<String>(
                              value: c.scheduler.value,
                              onChanged: (String? newValue) {
                                c.scheduler.value = newValue!;
                              },
                              items:
                                  c.availableSchedulers.map((String scheduler) {
                                return DropdownMenuItem<String>(
                                  value: scheduler,
                                  child: Text(scheduler),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ),

                      ListTile(
                        title: Text("全景图"),
                        onTap: () {
                          c.panorama.toggle();
                        },
                        trailing: Switch(
                            value: c.panorama.value,
                            onChanged: (it) {
                              c.panorama.toggle();
                            }),
                      ),

                      ListTile(
                        title: Text("高质量"),
                        onTap: () {
                          c.selfAttention.toggle();
                        },
                        trailing: Switch(
                            value: c.selfAttention.value,
                            onChanged: (it) {
                              c.selfAttention.toggle();
                            }),
                      ),

                      ListTile(
                        title: Text("使用 tomesd"),
                        onTap: () {
                          c.tomesd.toggle();
                        },
                        trailing: Switch(
                            value: c.tomesd.value,
                            onChanged: (it) {
                              c.tomesd.toggle();
                            }),
                      ),

                      ListTile(
                        title: Text("使用 KarrasSigmas"),
                        onTap: () {
                          c.useKarrasSigmas.toggle();
                        },
                        trailing: Switch(
                            value: c.useKarrasSigmas.value,
                            onChanged: (it) {
                              c.useKarrasSigmas.toggle();
                            }),
                      ),

                      SliderTile(
                        title: Text('推理步骤数: ${c.steps}'),
                        slider: Slider(
                          value: c.steps.toDouble(),
                          onChanged: (newValue) {
                            c.steps(newValue.toInt());
                          },
                          min: 1,
                          max: 50,
                          divisions: 50,
                          label: '推理步骤数: ${c.steps}',
                        ),
                      ),

                      SliderTile(
                        title: Text(
                            'guidanceScale: ${c.guidanceScale.toStringAsFixed(2)}'),
                        slider: Slider(
                          value: c.guidanceScale.value,
                          onChanged: (newValue) {
                            c.guidanceScale(newValue);
                          },
                          min: 1,
                          max: 20,
                          divisions: 19 * 2,
                          label: '${c.guidanceScale.toStringAsFixed(2)}',
                        ),
                      ),

                      SliderTile(
                        title: Text(
                            '放大分辨率x倍: ${c.upscale == 0 ? "不放大" : "${c.upscale} 倍"}'),
                        slider: Slider(
                          value: c.upscale.toDouble(),
                          onChanged: (newValue) {
                            c.upscale(newValue.toInt());
                          },
                          min: 0,
                          max: 3,
                          divisions: 3,
                          label: '${c.upscale}',
                        ),
                      ),

                      SliderTile(
                        title: Text('clipSkip: ${c.clipSkip}'),
                        slider: Slider(
                          value: c.clipSkip.toDouble(),
                          onChanged: (newValue) {
                            c.clipSkip(newValue.toInt());
                          },
                          min: 1,
                          max: 8,
                          divisions: 7,
                          label: '${c.clipSkip}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 0.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Generate images
                          generate(context);
                        },
                        child: Text('生成'),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('输出图像：'),
                          SizedBox(height: 8.0),
                          ListView.separated(
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
                              return ContextMenuRegion(
                                contextMenuBuilder:
                                    (BuildContext context, Offset offset) =>
                                        _buildContent(context, offset, image),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: image,
                                    placeholder: (context, url) => SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                                    errorWidget: (context, url, error) =>
                                        SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: Center(
                                                child: Icon(Icons.error))),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Offset offset, String imageUrl) {
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

  generate(BuildContext context) async {
    BuildContext? dialogContext;
    CancelToken cancelToken = CancelToken();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return AlertDialog(
          title: Text("请稍候"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("取消"))
          ],
        );
      },
    ).then((o) {
      cancelToken.cancel();
      dialogContext = null;
    });

    try {
      await c.generate(cancelToken);
    } catch (e, st) {
      print(e);
      Get.snackbar("失败", e.toString());
    } finally {
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
    }
  }
}

class OptionItem extends StatefulWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  OptionItem({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<OptionItem> createState() => _OptionItemState();
}

class _OptionItemState extends State<OptionItem> {
  final valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.title),
        SizedBox(width: 8.0),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter a value',
            ),
            controller: valueController,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

class OptionExplanationsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Option Explanations'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explanation 1'),
            SizedBox(height: 8.0),
            Text('Explanation 2'),
            SizedBox(height: 8.0),
            Text('Explanation 3'),
            // Add more explanations here
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class SliderTile extends StatelessWidget {
  final Widget title;
  final Slider slider;
  final Text? subtitle;

  const SliderTile({
    Key? key,
    required this.title,
    required this.slider,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(children: [
        Row(
          children: [
            title,
            if (subtitle != null) subtitle!,
          ],
        ),
        slider
      ]),
    );
  }
}
