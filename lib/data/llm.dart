import 'package:dart_openai/openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:get_storage/get_storage.dart';

abstract class LLM {
  getResponse(List<Message> messages, ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback, ValueChanged<Message> onSuccess);
}

class ChatGpt extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    List<OpenAIChatCompletionChoiceMessageModel> openAIMessages = [];
    //将messages反转
    messages = messages.reversed.toList();
    // 将messages里面的每条消息的内容取出来拼接在一起
    String content = "";
    for (Message message in messages) {
      content = content + message.text;
      if (content.length < 1800 || openAIMessages.isEmpty) {
        // 插入到 openAIMessages 第一个位置
        openAIMessages.insert(
          0,
          OpenAIChatCompletionChoiceMessageModel(
            content: message.text,
            role: message.role.asOpenAIChatMessageRole,
          ),
        );
      }
    }
    var message = Message(
        conversationId: messages.first.conversationId,
        text: "",
        role: Role.assistant); //仅仅第一个返回了角色
    if (SettingsController.to.useStream.value) {
      Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
          .createStream(
              model: GetStorage().read("gptModel") ?? "gpt-3.5-turbo",
              messages: openAIMessages);
      chatStream.listen(
        (chatStreamEvent) {
          if (chatStreamEvent.choices.first.delta.content != null) {
            message.text =
                message.text + chatStreamEvent.choices.first.delta.content!;
            onResponse(message);
          }
        },
        onError: (error) {
          message.text = error.message;
          errorCallback(message);
        },
        onDone: () {
          onSuccess(message);
        },
      );
    } else {
      try {
        var response = await OpenAI.instance.chat.create(
          model: GetStorage().read("gptModel") ?? "gpt-3.5-turbo",
          messages: openAIMessages,
        );
        message.text = response.choices.first.message.content;
        onSuccess(message);
      } catch (e) {
        message.text = e.toString();
        errorCallback(message);
      }
    }
  }
}
