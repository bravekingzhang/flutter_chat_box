part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  final List<Conversation> conversations;

  final String currentConversationUuid;

  const ConversationState(this.conversations, this.currentConversationUuid);

  @override
  List<Object> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial(super.conversations, super.currentConversationUuid);
}

class ConversationLoaded extends ConversationState {
  const ConversationLoaded(
    List<Conversation> conversations,
    String currentConversationUuid,
  ) : super(conversations, currentConversationUuid);

  @override
  List<Object> get props => [conversations];
}
