import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc() : super(const ConversationInitial([])) {
    on<LoadConversationsEvent>(_onLoadConversationsEvent);

    on<DeleteConversationEvent>(_onDeleteConversationEvent);

    on<UpdateConversationEvent>(_onUpdateConversationEvent);
  }

  Future<void> _onLoadConversationsEvent(
      LoadConversationsEvent event, Emitter<ConversationState> emit) async {
    final conversations = await ConversationRepository().getConversations();
    emit(ConversationLoaded(conversations));
  }

  Future<void> _onDeleteConversationEvent(
      DeleteConversationEvent event, Emitter<ConversationState> emit) async {
    await ConversationRepository().deleteConversation(event.conversation.uuid);
    final conversations = await ConversationRepository().getConversations();
    emit(ConversationLoaded(conversations));
  }

  Future<void> _onUpdateConversationEvent(
      UpdateConversationEvent event, Emitter<ConversationState> emit) async {
    await ConversationRepository().updateConversation(event.conversation);
    final conversations = await ConversationRepository().getConversations();
    emit(ConversationLoaded(conversations));
  }
}

