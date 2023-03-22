part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessagesLoaded extends MessageState {
  final List<Message> messages;

  const MessagesLoaded(
    this.messages,
  );

  @override
  List<Object> get props => [messages];
}

class MessageError extends MessageState {
  final String errorMessage;

  const MessageError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class MessageSending extends MessageState {
  const MessageSending();

  @override
  List<Object> get props => [];
}

class MessageLoading extends MessageState {
  const MessageLoading();

  @override
  List<Object> get props => [];
}

class MessageSentSuccess extends MessageState {
  final Message message;

  const MessageSentSuccess(this.message);

  @override
  List<Object> get props => [message];
}
