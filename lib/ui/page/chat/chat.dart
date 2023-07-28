import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_extensions/dart_extensions.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/data/network.dart';
import 'package:flutter_template/ui/widget/code_wrapper.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../widget/latex.dart';

class ChatPage extends StatelessWidget {
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: message.role == OpenAIChatMessageRole.user
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
                                child: Image.asset("images/wilinz.jpg"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          // 使用Flexible包装Card
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Builder(builder: (context) {
                                final config = Get.isDarkMode
                                    ? MarkdownConfig.darkConfig
                                    : MarkdownConfig.defaultConfig;
                                final codeWrapper = (child, text) =>
                                    CodeWrapperWidget(child: child, text: text);
                                return MarkdownWidget(
                                  shrinkWrap: true,
                                  data: message.content,
                                  config: config.copy(configs: [
                                    Get.isDarkMode
                                        ? PreConfig.darkConfig
                                            .copy(wrapper: codeWrapper)
                                        : PreConfig().copy(wrapper: codeWrapper)
                                  ]),
                                  markdownGeneratorConfig:
                                      MarkdownGeneratorConfig(
                                          generators: [latexGenerator],
                                          inlineSyntaxList: [LatexSyntax()]),
                                );
                              }),
                            ),
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
            child: Obx(() {
              return TextFormField(
                controller: c.inputController,
                autofocus: false,
                maxLines: 10,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: "消息",
                  hintText: "请输入消息",
                  suffixIcon: IconButton(
                      onPressed: c.inputNoBlank.value
                          ? () {
                              c.sendMessages();
                            }
                          : null,
                      icon: Icon(Icons.send)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                onChanged: (v) {
                  c.update();
                },
              );
            }),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
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
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void sendMessages() async {
    try {
      final msg = inputController.text;
      inputController.text = "";
      final message0 = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user, content: msg);
      messages.value.add(message0);

      final client = await AppNetwork.getRawHttpClient();
      Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
          .createStream(
              model: "gpt-3.5-turbo-16k-0613",
              messages: messages.value,
              client: client);

      final message = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant, content: "");
      messages.value.add(message);
      final index = messages.value.indexOf(message);

      chatStream.listen(
          (streamChatCompletion) {
            final content = streamChatCompletion.choices.first.delta.content;
            final old = messages.value[index];
            messages.value[index] = OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.assistant,
                content: old.content + (content ?? ""));
            _scrollToBottom();
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
