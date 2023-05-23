import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/data/llm.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGlM extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    var messageToBeSend = messages.removeLast();
    var prompt = messageToBeSend.text;
    var history = messages.length >= 2 ? collectHistory(messages) : [];
    var body = {'query': prompt, 'history': history.isEmpty ? [] : history};
    var glmBaseUrl = GetStorage().read("glmBaseUrl") ?? "";
    if (glmBaseUrl.isEmpty) {
      errorCallback(Message(
        text: "glm baseUrl is empty,please set you glmBaseUrl first",
        conversationId: messageToBeSend.conversationId,
        role: Role.assistant,
      ));
      return;
    }
    final request = http.Request("POST", Uri.parse(glmBaseUrl));
    request.headers.addAll({'Content-Type': 'application/json'});
    final requestBody = json.encode(body);
    request.body = requestBody;
    try {
      final response = await request.send();
      /**  chunk like this
     *  event: delta
     *   data: {"delta": "j", "response": "j", "finished": false}
     */
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        String data = chunk.split('\n').firstWhere(
            (element) => element.startsWith("data:"),
            orElse: () => 'No matching data');
        if (!data.startsWith("data:")) {
          continue;
        }
        final jsonData = jsonDecode(data.split("data:")[1].trim());
        if (jsonData["finished"]) {
          onSuccess(Message(
              conversationId: messageToBeSend.conversationId,
              text: jsonData["response"],
              role: Role.assistant));
        } else {
          onResponse(Message(
              conversationId: messageToBeSend.conversationId,
              text: jsonData["response"],
              role: Role.assistant));
        }
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

List<List<String>> collectHistory(List<Message> list) {
  List<List<String>> result = [];
  for (int i = list.length - 1; i >= 0; i -= 2) {
    //只添加最近的会话
    if (i - 1 > 0) {
      result.insert(0, [list[i - 1].text, list[i].text]);
    }
    if (result.length > 3) {
      //放太多轮次也没啥意思
      break;
    }
  }
  return result;
}
