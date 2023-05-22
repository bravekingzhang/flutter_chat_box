import 'dart:async';

import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/repository/message.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final messageList = <Message>[].obs;

  void loadAllMessages(String conversationUUid) async {
    messageList.value = await ConversationRepository()
        .getMessagesByConversationUUid(conversationUUid);
  }

  void addMessage(Message message) async {
    await ConversationRepository().addMessage(message);
    final messages = await ConversationRepository()
        .getMessagesByConversationUUid(message.conversationId);
    messageList.value = messages;
    // wait for all the  state emit
    final completer = Completer();
    try {
      MessageRepository().postMessage(message, (Message message) {
        messageList.value = [...messages, message];
      }, (Message message) {
        messageList.value = [...messages, message];
      }, (Message message) async {
        // if streaming is done ,load all the message
        ConversationRepository().addMessage(message);
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(message.conversationId);
        messageList.value = messages;
        completer.complete();
      });
    } catch (e) {
      messageList.value = [
        ...messages,
        Message(
            conversationId: message.conversationId,
            text: e.toString(),
            role: Role.assistant)
      ];
      completer.complete();
    }
    await completer.future;
  }
}
