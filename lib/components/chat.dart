import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc/conversation_bloc.dart';
import 'package:flutter_chatgpt/bloc/message_bloc.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';

class ChatWindow extends StatefulWidget {
  const ChatWindow({super.key});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 定义一个 GlobalKey
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: BlocBuilder<MessageBloc, MessageState>(
                  buildWhen: (previous, current) {
                    return current.runtimeType == MessagesLoaded;
                  },
                  builder: (context, state) {
                    if (state.runtimeType == MessagesLoaded) {
                      var currentState = state as MessagesLoaded;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: currentState.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageCard(
                              currentState.messages[index]);
                        },
                      );
                    } else {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return const Text('nothing');
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey, // 将 GlobalKey 赋值给 Form 组件的 key 属性
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: _handleKeyEvent,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Input your promote',
                          hintText: 'Input your promote here',
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          _sendMessage();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.send),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      final conversationUuid =
          context.read<ConversationBloc>().state.currentConversationUuid;
      final newMessage = Message(
        conversationId: conversationUuid,
        role: Role.user,
        text: message,
      );
      context.read<MessageBloc>().add(SendMessageEvent(newMessage));
      _formKey.currentState!.reset();
    }
  }

  Widget _buildMessageCard(Message message) {
    if (message.role == Role.user) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _handleKeyEvent(RawKeyEvent value) {
    if ((value.isKeyPressed(LogicalKeyboardKey.enter) &&
            value.isControlPressed) ||
        (value.isKeyPressed(LogicalKeyboardKey.enter) && value.isMetaPressed)) {
      _sendMessage();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
