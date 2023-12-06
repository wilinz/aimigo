
import 'package:aimigo/data/network.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

class ChatController extends GetxController {
  final messages = RxList<ChatMessage>().obs;

  final inputController = TextEditingController(text: "");
  var inputNoBlank = false.obs;
  ScrollController scrollController = ScrollController();

  clearMessage() {
    messages.value.clear();
    final message0 = ChatMessage(
        role: ChatMessageRole.system, content: "您好，有什么需要帮助的吗？");
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
      final message0 = ChatMessage(
          role: ChatMessageRole.user, content: msg);
      //将消息加入消息列表
      messages.value.add(message0);
      //滚到列表底部
      // _scrollToBottom();

      //调用 createStream
      final chatStream = AppNetwork.get().openAiClient.chatCompletionApi.createChatCompletionStream(
          ChatCompletionRequest(messages: messages.value, model: "gpt-3.5-turbo-16k-0613")
      );

      //构建响应消息
      final message = ChatMessage(
          role: ChatMessageRole.assistant, content: "");
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
              messages.value[index] = ChatMessage(
                  role: ChatMessageRole.assistant,
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
