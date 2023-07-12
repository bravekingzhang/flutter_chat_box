import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/data/llm.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class YouAi extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    var messageToBeSend = messages.removeLast();
    var body = {
      "code": SettingsController.to.youCode.value,
      "messages": zipMessage(messages), // messages 必填
      "stream": true, //  是否流式输出
      "model": SettingsController.to.gptModel.value, // 选择模型必填
      "vip": false
    };
    final request =
        http.Request("POST", Uri.parse("https://bard.brzhang.club/api/chat"));
    request.headers.addAll({'Content-Type': 'application/json'});
    final requestBody = json.encode(body);
    request.body = requestBody;
    try {
      final response = await request.send();
      var content = "";
      var currentData = "";
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // ignore: prefer_typing_uninitialized_variables
        var response;
        // debugPrint(chunk);
        currentData = currentData + chunk;
        debugPrint(currentData);

        if (currentData.contains("data:") && !currentData.contains("[DONE]")) {
          try {
            response = jsonDecode(currentData.split("data:")[1].trim());
          } catch (e) {
            // ignore: avoid_print
            response = null;
            continue;
          }
        }
        if (response != null && response["choices"] != null) {
          currentData = "";
          OpenAIStreamChatCompletionModel model =
              OpenAIStreamChatCompletionModel.fromMap(response);
          content = content + model.choices[0].delta.content!;
          onResponse(Message(
              conversationId: messageToBeSend.conversationId,
              text: content,
              role: Role.assistant));
        } else if (currentData.contains('[DONE]')) {
          onSuccess(Message(
              conversationId: messageToBeSend.conversationId,
              text: content,
              role: Role.assistant));
        } else {
          errorCallback(Message(
              conversationId: messageToBeSend.conversationId,
              text: currentData,
              role: Role.assistant));
        }
        debugPrint(content);
      }
    } catch (e) {
      errorCallback(Message(
        text: e.toString(),
        conversationId: messageToBeSend.conversationId,
        role: Role.assistant,
      ));
    }
  }
}

/* [
        {"role": "user", "content": "你能为了做什么，你是谁"}
      ] */
List<MessageObj> zipMessage(List<Message> list) {
  String currentModel = SettingsController.to.gptModel.value;
  int maxTokenLength = 1800;
  switch (currentModel) {
    case "gpt-3.5-turbo":
      maxTokenLength = 1800;
      break;
    case "gpt-3.5-turbo-16k":
      maxTokenLength = 10000;
      break;
    default:
      maxTokenLength = 1800;
      break;
  }
  // bool useWebSearch = SettingsController.to.useWebSearch.value;
  // if (useWebSearch) {
  //   messages.first.text = await fetchAndParse(messages.first.text);
  // }
  var content = "";
  var messages = list.reversed.toList();
  List<MessageObj> toBeSendMessages = [];
  for (Message message in messages) {
    content = content + message.text;
    if (content.length < maxTokenLength || toBeSendMessages.isEmpty) {
      // 插入到 openAIMessages 第一个位置
      toBeSendMessages.insert(
        0,
        MessageObj(
          content: message.text,
          role: toRoleString(message.role),
        ),
      );
    }
  }
  return toBeSendMessages;
}

toRoleString(Role role) {
  switch (role) {
    case Role.assistant:
      return "assistant";
    case Role.user:
      return "user";
    case Role.system:
      return "system";
  }
}

class MessageObj {
  String content;
  String role;

  MessageObj({required this.content, required this.role});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'role': role,
    };
  }
}
