import 'dart:ui';

import 'package:dart_openai/openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/utils/log.dart';

class MessageRepository {
  static final MessageRepository _instance = MessageRepository._internal();

  factory MessageRepository() {
    return _instance;
  }

  MessageRepository._internal() {
    init("");
  }

  void postMessage(Message message, ValueChanged<Message> onResponse,
      ValueChanged<Message> onError, VoidCallback onSuccess) async {
    ConversationRepository().addMessage(message);
    List<Message> messages = await ConversationRepository()
        .getMessagesByConversationUUid(message.conversationId);
    _getResponseFromGpt(messages, onResponse, onError, onSuccess);
  }

  void init(apiKey) {
    OpenAI.apiKey = "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";
  }

  void _getResponseFromGpt(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      VoidCallback onSuccess) {
    List<OpenAIChatCompletionChoiceMessageModel> openAIMessages = messages
        .map((message) => OpenAIChatCompletionChoiceMessageModel(
              content: message.text,
              role: message.role.toString().split('.').last,
            ))
        .toList();
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(model: "gpt-3.5-turbo", messages: openAIMessages);
    var message = Message(
        conversationId: messages.first.conversationId,
        text: "",
        role: Role.assistant); //仅仅第一个返回了角色
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
        ConversationRepository().addMessage(message);
        onSuccess();
      },
    );
  }

  deleteMessage(int messageId) {
    ConversationRepository().deleteMessage(messageId);
  }
}
