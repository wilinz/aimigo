import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aimigo/data/network.dart';
import 'package:aimigo/ui/page/common.dart';
import 'package:aimigo/ui/widget/code_wrapper.dart';
import 'package:aimigo/ui/widget/markdown_block.dart';
import 'package:aimigo/ui/widget/selection_transformer.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/tts/tts.dart';
import '../../widget/latex.dart';

class MyMarkdownController extends GetxController {
  late OpenAIChatCompletionChoiceMessageModel message;
  var isSourceMode = false.obs;

  MyMarkdownController({required this.message});

  Future<void> textToSpeech() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(join(supportDir.path, 'tts'));
    await dir.create(recursive: true);

    final file =
        File(join(dir.path, DateTime.now().millisecond.toString() + ".mp3"));

    final sink = file.openWrite();
    final stream =
        tts(message.content, language: "zh_CN", voiceName: "zh-CN-YunxiNeural");
    stream.listen((bytes) {
      sink.add(bytes);
    }, onDone: () async {
      sink.close();
      final player = AudioPlayer();
      player.play(DeviceFileSource(file.path));
      player.onPlayerComplete.listen((event) {
        file.delete();
      });
    });
  }
}

class MyMarkdownWidget extends StatefulWidget {
  final OpenAIChatCompletionChoiceMessageModel message;

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
      return MyMarkdownBlock(
        data:
            widget.message.content.isNotEmpty ? widget.message.content : "...",
        isSourceMode: c.isSourceMode.value,
        builder: (child) {
          return SelectionArea(
            child: SelectionTransformer.separated(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: child,
              )
            ),
            contextMenuBuilder: (context, editableTextState) {
              final TextEditingValue value = editableTextState.textEditingValue;
              final items = editableTextState.contextMenuButtonItems
                  .map((e) => getLocalizedContextMenuButtonItem(e))
                  .toList();
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
        markdownGeneratorConfig: MarkdownGeneratorConfig(
            generators: [latexGenerator], inlineSyntaxList: [LatexSyntax()]),
      );
    });
  }

  ContextMenuButtonItem getLocalizedContextMenuButtonItem(
      ContextMenuButtonItem e) {
    switch (e.type) {
      //GetTheLocalizedContextMenuButtonItem
      case ContextMenuButtonType.copy:
        return e.copyWith(label: "复制");
      case ContextMenuButtonType.selectAll:
        return e.copyWith(label: "全选");
      case ContextMenuButtonType.cut:
        return e.copyWith(label: "剪切");
      case ContextMenuButtonType.paste:
        return e.copyWith(label: "粘贴");
      case ContextMenuButtonType.delete:
        return e.copyWith(label: "删除");
      case ContextMenuButtonType.liveTextInput:
      case ContextMenuButtonType.custom:
        return e;
    }
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

class _ChatPageState extends State<ChatPage>  with AutomaticKeepAliveClientMixin {
  final ChatController c = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('聊天'),
          actions: [
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
                        textDirection:
                            message.role == OpenAIChatMessageRole.user
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
                                  child: Image.asset("assets/images/wilinz.jpg"),
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
                padding: const EdgeInsets.all(16),
                child: Shortcuts(
                    shortcuts: <ShortcutActivator, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.control,
                          LogicalKeyboardKey.enter): const SendMessageIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        SendMessageIntent: CallbackAction<SendMessageIntent>(
                            onInvoke: _sendMessage),
                      },
                      child: Obx(() => TextFormField(
                            controller: c.inputController,
                            autofocus: false,
                            maxLines: 10,
                            minLines: 1,
                            decoration: InputDecoration(
                              labelText: "消息",
                              hintText: "请输入消息",
                              suffixIcon: IconButton(
                                  onPressed: c.inputNoBlank.value
                                      ? c.sendMessages
                                      : null,
                                  icon: Icon(Icons.send)),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                            ),
                            onChanged: (v) {
                              c.update();
                            },
                          )),
                    ))),
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

class ChatController extends GetxController {
  final messages = RxList<OpenAIChatCompletionChoiceMessageModel>().obs;

  final inputController = TextEditingController(text: "");
  var inputNoBlank = false.obs;
  ScrollController scrollController = ScrollController();

  clearMessage() {
    messages.value.clear();
    final message0 = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system, content: "您好，有什么需要帮助的吗？");
    messages.value.add(message0);
  }

  @override
  void onInit() {
    super.onInit();
    clearMessage();
    inputController.addListener(() {
      inputNoBlank.value = inputController.text.isNotBlank;
    });
  }

  void _scrollToBottom() {
    try {
      scrollController.jumpTo(
            scrollController.position.maxScrollExtent,
            // duration: Duration(milliseconds: 10),
            // curve: Curves.easeInOut,
          );
    } catch (e) {
      print(e);
    }
  }

  void sendMessages() async {
    try {
      //获取消息
      final msg = inputController.text;
      //清空输入
      inputController.text = "";
      //构建用户消息
      final message0 = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: msg);
      //将消息加入消息列表
      messages.value.add(message0);
      //滚到列表底部
      _scrollToBottom();

      //调用 createStream
      final client = await AppNetwork.getRawHttpClient();
      Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
          .createStream(
              model: "gpt-3.5-turbo-16k-0613",
              messages: messages.value,
              client: client);

      //构建响应消息
      final message = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant, content: "");
      //将消息加入消息列表
      messages.value.add(message);
      //获取消息 index
      final index = messages.value.indexOf(message);

      //监听响应
      chatStream.listen(
          (streamChatCompletion) {
            try {
              //获取响应内容
              final content = streamChatCompletion.choices.first.delta.content;
              //获取旧消息
              final old = messages.value[index];
              //更新消息
              messages.value[index] = OpenAIChatCompletionChoiceMessageModel(
                  role: OpenAIChatMessageRole.assistant,
                  //追加拼接内容
                  content: old.content + (content ?? ""));
              //滚到列表底部
              _scrollToBottom();
            } catch (e) {
              print(e);
            }
          },
          onDone: () {},
          onError: (e, s) {
            print(e);
            print(s);
          });

      // final chat = await OpenAI.instance.chat.create(
      //     model: "gpt-3.5-turbo-16k-0613",
      //     messages: [
      //       OpenAIChatCompletionChoiceMessageModel(
      //         content: inputController.text,
      //         role: OpenAIChatMessageRole.user,
      //       )
      //     ],
      //     client: client);
      // print(chat);
      // 处理API响应并更新消息列表
      // ...
    } catch (error, st) {
      print(error);
      print(st);
      // 处理错误
      // ...
    }
  }
}
