part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class AddConversationEvent extends ConversationEvent {
  final Conversation conversation;

  const AddConversationEvent(this.conversation);

  @override
  List<Object> get props => [conversation];

  @override
  String toString() => 'AddConversation { conversation: $conversation }';
}

class DeleteConversationEvent extends ConversationEvent {
  final Conversation conversation;

  const DeleteConversationEvent(this.conversation);

  @override
  List<Object> get props => [conversation];

  @override
  String toString() => 'DeleteConversation { conversation: $conversation }';
}

class LoadConversationsEvent extends ConversationEvent {
  const LoadConversationsEvent();

  @override
  String toString() => 'LoadConversations';
}

class UpdateConversationEvent extends ConversationEvent {
  final Conversation conversation;

  const UpdateConversationEvent(this.conversation);

  @override
  List<Object> get props => [conversation];

  @override
  String toString() => 'UpdateConversation { conversation: $conversation }';
}

class ChooseConversationEvent extends ConversationEvent {
  final String conversationUUid;

  const ChooseConversationEvent(this.conversationUUid);
}
