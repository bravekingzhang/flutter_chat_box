part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  final List<Conversation> conversations;

  const ConversationState(this.conversations);

  @override
  List<Object> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial(super.conversations);
}

class ConversationLoaded extends ConversationState {
  const ConversationLoaded(List<Conversation> conversations)
      : super(conversations);

  @override
  List<Object> get props => [conversations];
}
