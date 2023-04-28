import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc/conversation_bloc.dart';
import 'package:flutter_chatgpt/bloc/message_bloc.dart';
import 'package:flutter_chatgpt/components/markdown.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

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
                  builder: (context, state) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToNewMessage();
                    });
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
                      return _buildExpandEmptyListView();
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
                          labelText: AppLocalizations.of(context)!.inputPrompt,
                          hintText:
                              AppLocalizations.of(context)!.inputPromptTips,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
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

  String _newConversation(String name, String description) {
    var conversation = Conversation(
      name: name,
      description: description,
      uuid: uuid.v4(),
    );
    BlocProvider.of<ConversationBloc>(context).add(
      AddConversationEvent(
        conversation,
      ),
    );
    return conversation.uuid;
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      var conversationUuid =
          context.read<ConversationBloc>().state.currentConversationUuid;
      if (conversationUuid.isEmpty) {
        // new conversation
        conversationUuid = _newConversation(message, message);
      }
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              FaIcon(FontAwesomeIcons.person),
              SizedBox(
                width: 5,
              ),
              Text("User"),
              SizedBox(
                width: 10,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        message.text,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              const FaIcon(FontAwesomeIcons.robot),
              const SizedBox(
                width: 5,
              ),
              Text(message.role == Role.system ? "System" : "assistant"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Markdown(text: message.text),
                ),
              ),
            ],
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
    }
  }

  void _scrollToNewMessage() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Widget _buildExpandEmptyListView() {
    if (MediaQuery.of(context).size.width > FormFactor.tablet) {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: sceneList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => {
              _controller.text = (sceneList[index]["description"] as String)
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sceneList[index]["color"] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${sceneList[index]["title"]}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      '${sceneList[index]["description"]}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 3,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: sceneList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => {
              _controller.text = (sceneList[index]["description"] as String)
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sceneList[index]["color"] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${sceneList[index]["title"]}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${sceneList[index]["description"]}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

var sceneList = [
  {
    "title": "前端开发",
    "color": Colors.blue[300],
    "description":
        "需要你扮演技术精湛的前端开发工程师，解决前端问题需要你扮演技术精湛的前端开发工程师，解决前端问题需要你扮演技术精湛的前端开发工程师，解决前端问题需要你扮演技术精湛的前端开发工程师，解决前端问题"
  },
  {
    "title": "后端开发",
    "color": Colors.green[300],
    "description": "需要你扮演技术精湛的后端开发工程师，解决后端问题"
  },
  {
    "title": "数据分析师",
    "color": Colors.purple[300],
    "description": "需要你扮演数据分析师，解决数据分析问题"
  },
  {
    "title": "测试工程师",
    "color": Colors.orange[300],
    "description": "需要你扮演测试工程师，解决测试问题"
  },
  {
    "title": "运维工程师",
    "color": Colors.red[300],
    "description": "需要你扮演运维工程师，解决运维问题"
  },
  {
    "title": "产品经理",
    "color": Colors.blueGrey[300],
    "description": "需要你扮演产品经理，解决产品问题"
  },
  {
    "title": "UI设计师",
    "color": Colors.pink[300],
    "description": "需要你扮演UI设计师，解决UI设计问题"
  }
];
