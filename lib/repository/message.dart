import 'package:flutter_chatgpt/repository/conversation.dart';

class MessageRepository {
  static final MessageRepository _instance = MessageRepository._internal();

  factory MessageRepository() {
    return _instance;
  }

  MessageRepository._internal();

  postMessage(Message message) {
    ConversationRepository().addMessage(message);
    // Mock ChatGPT response
    String response = "Hi there! How can I assist you today?";
    // Create a new message with the ChatGPT response
    Message botMessage = Message(
        text: response,
        role: Role.assistant,
        conversationId: message.conversationId);
    // Add the message to the conversation
    ConversationRepository().addMessage(botMessage);
  }

  deleteMessage(int messageId) {
    ConversationRepository().deleteMessage(messageId);
  }
}
