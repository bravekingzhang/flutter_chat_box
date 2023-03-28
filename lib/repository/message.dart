import 'dart:ui';

import 'package:dart_openai/openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/cubit/setting_cubit.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/utils/log.dart';
import 'package:get_it/get_it.dart';

class MessageRepository {
  static final MessageRepository _instance = MessageRepository._internal();

  factory MessageRepository() {
    return _instance;
  }

  MessageRepository._internal() {
    init();
  }

  void postMessage(Message message, ValueChanged<Message> onResponse,
      ValueChanged<Message> onError, ValueChanged<Message> onSuccess) async {
    List<Message> messages = await ConversationRepository()
        .getMessagesByConversationUUid(message.conversationId);
    _getResponseFromGpt(messages, onResponse, onError, onSuccess);
  }

  void init() {
    OpenAI.apiKey = GetIt.instance.get<UserSettingCubit>().state.key;
    OpenAI.baseUrl = GetIt.instance.get<UserSettingCubit>().state.baseUrl;
  }

  void _getResponseFromGpt(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) {
    List<OpenAIChatCompletionChoiceMessageModel> openAIMessages = messages
        .map((message) => OpenAIChatCompletionChoiceMessageModel(
              content: message.text,
              role: message.role.toString().split('.').last,
            ))
        .toList();
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(
            model: GetIt.instance.get<UserSettingCubit>().state.gptModel,
            messages: openAIMessages);
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
        onSuccess(message);
      },
    );
  }

  deleteMessage(int messageId) {
    ConversationRepository().deleteMessage(messageId);
  }
}
