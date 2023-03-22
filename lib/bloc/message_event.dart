part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends MessageEvent {
  final Message message;

  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteMessageEvent extends MessageEvent {
  final Message message;

  const DeleteMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class LoadAllMessagesEvent extends MessageEvent {
  final String conversationUUid;
  const LoadAllMessagesEvent(this.conversationUUid);

  @override
  List<Object> get props => [conversationUUid];
}
