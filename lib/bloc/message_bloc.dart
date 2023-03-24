import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/repository/message.dart';
import 'package:flutter_chatgpt/utils/log.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    var index = 1;
    on<SendMessageEvent>((event, emit) async {
      emit(const MessageSending());
      await ConversationRepository().addMessage(event.message);
      final messages = await ConversationRepository()
          .getMessagesByConversationUUid(event.message.conversationId);
      emit(MessagesLoaded(messages));
      // wait for all the  state emit
      final completer = Completer();
      try {
        MessageRepository().postMessage(event.message, (Message message) {
          log("这里发送了多少次数据了${index++}");
          emit(MessagesLoaded([...messages, message]));
        }, (Message message) {
          emit(MessagesLoaded([...messages, message]));
        }, (Message message) async {
          // if streaming is done ,load all the message
          ConversationRepository().addMessage(message);
          final messages = await ConversationRepository()
              .getMessagesByConversationUUid(event.message.conversationId);
          emit(MessagesLoaded(messages));
          completer.complete();
        });
      } catch (e) {
        emit(MessageError(e.toString()));
        completer.complete();
      }
      await completer.future;
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
            .getMessagesByConversationUUid(event.conversationUUid);
        emit(MessagesLoaded(messages));
      } catch (e) {
        emit(MessageError(e.toString()));
      }
    });
  }
}
