import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:get/get.dart';

class ConversationController extends GetxController {
  final conversationList = <Conversation>[].obs;

  final currentConversationUuid = "".obs;

  static ConversationController get to => Get.find();
  @override
  void onInit() async {
    conversationList.value = await ConversationRepository().getConversations();
    super.onInit();
  }

  void setCurrentConversationUuid(String uuid) {
    currentConversationUuid.value = uuid;
  }

  void deleteConversation(int index) async {
    Conversation conversation = conversationList[index];
    await ConversationRepository().deleteConversation(conversation.uuid);
    conversationList.value = await ConversationRepository().getConversations();
  }

  void renameConversation(Conversation conversation) async {
    await ConversationRepository().updateConversation(conversation);
    conversationList.value = await ConversationRepository().getConversations();
  }
}
