import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/data/llm.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGlM extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    var prompt = messages.removeLast().text;
    var history = messages.length >= 2 ? collectHistory(messages) : [];
    var body = {'prompt': prompt, 'history': history.isEmpty ? [] : history};
    final response = await http.post(
        Uri.parse('https://eafd-124-65-196-6.ngrok-free.app/'),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      var jsonObj = jsonDecode(utf8.decode(response.bodyBytes));

      ///TODO: 流式响应
      // onResponse(Message(
      //   text: jsonObj['response'],
      //   conversationId: messages.last.conversationId,
      //   role: Role.assistant,
      // ));
      onSuccess(Message(
        text: jsonObj['response'],
        conversationId: messages.last.conversationId,
        role: Role.assistant,
      ));
    } else {
      errorCallback(Message(
        text: "request glm error,Please try again later",
        conversationId: messages.last.conversationId,
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
      result.insert(0, [list[-1].text, list[i].text]);
    }
    if (result.length > 3) {
      //放太多轮次也没啥意思
      break;
    }
  }
  return result;
}
