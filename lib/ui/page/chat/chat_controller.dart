import 'dart:io';

import 'package:aimigo/data/network.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openai_dart_dio/openai_dart_dio.dart';

class ChatController extends GetxController {
  final messages = RxList<ChatMessage>().obs;

  final inputController = TextEditingController(text: "");
  var inputNoBlank = false.obs;
  ScrollController scrollController = ScrollController();

  final models = <OpenAiModel>[].obs;
  final model = Rx<OpenAiModel?>(null);
  final picker = ImagePicker();
  final images = <File>[].obs;

  clearMessage() {
    messages.value.clear();
    final message0 =
        ChatMessage(role: ChatMessageRole.system, content: "您好，有什么需要帮助的吗？");
    messages.value.add(message0);
  }

  @override
  void onInit() {
    super.onInit();
    clearMessage();
    inputController.addListener(() {
      inputNoBlank.value = inputController.text.isNotBlank;
    });
    setupModels();
  }

  Future<void> setupModels() async {
    final client = AppNetwork.get().openAiClient;
    if (client != null) {
      try {
        final resp = await client.modelApi.list();
        final respModels =
            resp.data.filter((e) => e.id.startsWith("gpt")).toList();
        respModels.sort((a, b) {
          final aDate = DateTime.fromMillisecondsSinceEpoch(a.created * 1000);
          final bDate = DateTime.fromMillisecondsSinceEpoch(b.created * 1000);
          if (aDate == bDate) return 0;
          return aDate.isBefore(bDate) ? 1 : -1;
        });
        model.value = respModels.firstOrNull;
        models.value = respModels;
      } catch (e) {
        print(e);
      }
    }
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

  Future getImages() async {
    final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1024, maxHeight: 1024, imageQuality: null);
    if (pickedFiles.isNotEmpty) {
      images.addAll(
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
    } else {
      print('No images selected.');
    }
  }

  void sendMessages() async {
    try {
      final chatModel = model.value?.id;
      if (chatModel == null) {
        Get.snackbar("失败", "未选择 GPT 模型");
        return;
      }

      if (images.isNotEmpty) {
        if (chatModel.contains("gpt-3.5")) {
          Get.snackbar("失败", "请切换更高级的支持图片的模型");
          return;
        }
      }

      //获取消息
      final msg = inputController.text;
      //清空输入
      inputController.text = "";

      ChatMessage message0;
      int? maxToken;
      //构建用户消息
      if (images.isNotEmpty) {
        maxToken = 4096;
        final openaiImages = await Future.wait(images.map((e) async {
          final stream = e.openRead();
          return MessageContent.fromImage(
              await OpenAiImageInfo.fromStream(stream));
        }));
        message0 = ChatMessage(
            role: ChatMessageRole.user,
            content: <MessageContent>[
              MessageContent.fromText(msg),
              ...openaiImages
            ]);
        images([]);
      }else{
        message0 = ChatMessage(role: ChatMessageRole.user, content: msg);
      }

      //将消息加入消息列表
      messages.value.add(message0);
      //滚到列表底部
      // _scrollToBottom();

      //调用 createStream
      final client = AppNetwork.get().openAiClient;
      if (client == null) {
        Get.snackbar("您未配置 openai ", "请前往“个人主页”->“设置”，配置“Api key”");
        return;
      }
      final chatStream = client.chatCompletionApi.createChatCompletionStream(
          ChatCompletionRequest(messages: messages.value, model: chatModel, maxTokens: maxToken));

      //构建响应消息
      final message = ChatMessage(role: ChatMessageRole.assistant, content: "");
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
              // _scrollToBottom();
            } catch (e) {
              print(e);
            }
          },
          onDone: () {
            print("完成");
          },
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
