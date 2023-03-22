import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/repository/message.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<SendMessageEvent>((event, emit) async {
      emit(const MessageSending());
      try {
        await MessageRepository().postMessage(event.message);
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.message.conversationId);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });

    on<DeleteMessageEvent>((event, emit) async {
      try {
        await ConversationRepository().deleteMessage(event.message.id!);
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.message.conversationId);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });

    on<LoadAllMessagesEvent>((event, emit) async {
      emit(const MessageLoading());
      try {
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(event.message.conversationId);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });
  }
}
