import 'dart:io';

import 'package:aimigo/ui/page/chat/chat_controller.dart';
import 'package:aimigo/ui/page/chat/markdown_controller.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aimigo/ui/page/common.dart';
import 'package:aimigo/ui/widget/code_wrapper.dart';
import 'package:aimigo/ui/widget/markdown_block.dart';
import 'package:aimigo/ui/widget/selection_transformer.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

import '../../widget/latex.dart';

class MyMarkdownWidget extends StatefulWidget {
  final ChatMessage message;

  MyMarkdownWidget(this.message, {Key? key}) : super(key: key) {}

  @override
  State<MyMarkdownWidget> createState() => _MyMarkdownWidgetState();
}

class _MyMarkdownWidgetState extends State<MyMarkdownWidget> {
  late final MyMarkdownController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(MyMarkdownController(message: widget.message),
        tag: this.hashCode.toString());
  }

  @override
  Widget build(BuildContext context) {
    c.message = widget.message;
    final config = Get.isDarkMode
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    final codeWrapper =
        (child, text) => CodeWrapperWidget(child: child, text: text);

    return Obx(() {
      String? data = c.message.content is String?
          ? c.message.contentAsString
          : c.message.contentAsMessageContentList
              ?.firstWhere((e) => e.type == MessageContentType.text)
              .text;

      String? mkImageList;
      if (!(c.message.content is String?)) {
        int i = 1;
        mkImageList = c.message.contentAsMessageContentList!
            .filter((e) => e.imageUrl != null)
            .map((e) {
              final mk = "![img$i](${e.imageUrl!.url})";
              i++;
              return mk;
            })
            .toList()
            .join("\n");
      }

      if (data == null) data = "...";
      final mkData = mkImageList != null ? (data + "  \n" + mkImageList) : data;
      return MyMarkdownBlock(
        data: mkData,
        isSourceMode: c.isSourceMode.value,
        builder: (child) {
          return SelectionArea(
            child: SelectionTransformer.separated(
                child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: child,
            )),
            contextMenuBuilder: (context, editableTextState) {
              final TextEditingValue value = editableTextState.textEditingValue;
              final items = editableTextState.contextMenuButtonItems.toList();
              items.addAll([
                ContextMenuButtonItem(
                    onPressed: () {
                      c.isSourceMode.toggle();
                    },
                    label: c.isSourceMode.value ? "富文本" : "源文本"),
                ContextMenuButtonItem(
                    onPressed: () {
                      c.textToSpeech();
                    },
                    label: "播放"),
                ContextMenuButtonItem(onPressed: () {}, label: "发送"),
                ContextMenuButtonItem(onPressed: () {}, label: "截图")
              ]);
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: items,
              );
            },
          );
        },
        config: config.copy(configs: [
          Get.isDarkMode
              ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
              : PreConfig().copy(wrapper: codeWrapper)
        ]),
        generator: MarkdownGenerator(
            generators: [latexGenerator], inlineSyntaxList: [LatexSyntax()]),
      );
    });
  }

  final selectionToolbarButtonStyle = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  @override
  void dispose() {
    super.dispose();
    Get.delete(tag: this.hashCode.toString());
  }
}

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  final ChatController c = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('聊天'),
          actions: [
            Obx(() => c.models.isEmpty
                ? IconButton(
                    onPressed: () {
                      if (c.models.isEmpty) {
                        c.setupModels();
                      }
                    },
                    icon: Icon(Icons.sync))
                : Tooltip(
                    message: c.model.value?.id ?? "未选择",
                    child: DropdownButton<OpenAiModel>(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      hint: Text("未选择"),
                      value: c.model.value,
                      focusColor: Colors.transparent,
                      // 设置焦点颜色为透明
                      items: c.models
                          .map((e) => DropdownMenuItem<OpenAiModel>(
                                value: e,
                                child: Text(
                                  e.id,
                                  style: TextStyle(
                                      color: c.model == e
                                          ? Colors.green
                                          : null),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        c.model.value = value!;
                      },
                      selectedItemBuilder: (context) {
                        return c.models
                            .map((e) => DropdownMenuItem<OpenAiModel>(
                                  value: e,
                                  child: SizedBox(
                                      width: 100,
                                      child: Text(
                                        e.id,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ))
                            .toList();
                      },
                    ),
                  )),
            IconButton(
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: Text("清空"),
                    content: Text("清空聊天记录"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("取消")),
                      TextButton(
                          onPressed: () {
                            c.clearMessage();
                            Get.back();
                          },
                          child: Text("确定"))
                    ],
                  ));
                },
                icon: Icon(Icons.delete_forever_outlined))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  controller: c.scrollController,
                  itemCount: c.messages.value.length,
                  itemBuilder: (context, index) {
                    final message = c.messages.value[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: message.role == ChatMessageRole.user
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: Offset(0, 2),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: SizedBox.square(
                                  dimension: 48,
                                  child:
                                      Image.asset("assets/images/wilinz.jpg"),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            // 使用Flexible包装Card
                            child: Card(
                              child: MyMarkdownWidget(message),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Obx(() => c.images.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Color(0x10555555),
                              ),
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: c.images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Material(
                                        elevation: 8,
                                        child: Stack(children: [
                                          Image.file(
                                            c.images[index],
                                            height: 200,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    c.images.removeAt(index);
                                                  });
                                                },
                                                icon: Icon(Icons.clear)),
                                          )
                                        ]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container()),
                    Shortcuts(
                        shortcuts: <ShortcutActivator, Intent>{
                          LogicalKeySet(LogicalKeyboardKey.control,
                                  LogicalKeyboardKey.enter):
                              const SendMessageIntent(),
                        },
                        child: Actions(
                          actions: <Type, Action<Intent>>{
                            SendMessageIntent:
                                CallbackAction<SendMessageIntent>(
                                    onInvoke: _sendMessage),
                          },
                          child: Obx(() => TextFormField(
                                controller: c.inputController,
                                autofocus: false,
                                maxLines: 10,
                                minLines: 1,
                                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  labelText: "消息",
                                  hintText: "请输入消息",
                                  prefixIcon: IconButton(
                                      onPressed: c.getImages,
                                      icon: Icon(Icons.photo_album_outlined)),
                                  suffixIcon: IconButton(
                                      onPressed: c.inputNoBlank.value
                                          ? c.sendMessages
                                          : null,
                                      icon: Icon(Icons.send)),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16))),
                                ),
                                onChanged: (v) {
                                  c.update();
                                },
                              )),
                        )),
                    Row(
                      children: [],
                    )
                  ],
                )),
            SizedBox(height: 8)
          ],
        ));
  }

  void _sendMessage(SendMessageIntent intent) {
    c.sendMessages();
  }

  @override
  bool get wantKeepAlive => true;
}
