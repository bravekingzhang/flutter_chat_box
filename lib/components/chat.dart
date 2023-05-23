import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/components/markdown.dart';
import 'package:flutter_chatgpt/controller/conversation.dart';
import 'package:flutter_chatgpt/controller/message.dart';
import 'package:flutter_chatgpt/controller/prompt.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  final ConversationController conversationController =
      Get.put(ConversationController());

  @override
  void initState() {
    super.initState();
  }

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
                child: GetX<MessageController>(
                  builder: (controller) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToNewMessage();
                    });
                    if (controller.messageList.isNotEmpty) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: controller.messageList.length,
                        itemBuilder: (context, index) {
                          return _buildMessageCard(
                              controller.messageList[index]);
                        },
                      );
                    } else {
                      return GetX<PromptController>(builder: ((controller) {
                        if (controller.prompts.isEmpty) {
                          return ListView(
                              controller: _scrollController,
                              children: const [
                                Center(
                                  child: Center(child: Text("正在加载prompts...")),
                                )
                              ]);
                        } else if (controller.prompts.isNotEmpty) {
                          return _buildExpandEmptyListView(controller.prompts);
                        } else {
                          return ListView(
                              controller: _scrollController,
                              children: const [
                                Center(
                                  child: Center(
                                      child: Text("加载prompts列表失败，请检查网络")),
                                )
                              ]);
                        }
                      }));
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
                          labelText: "inputPrompt".tr,
                          hintText: "inputPromptTips".tr,
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
    return conversation.uuid;
  }

  void _sendMessage() {
    final message = _controller.text;
    final MessageController messageController = Get.find();
    final ConversationController conversationController = Get.find();
    if (message.isNotEmpty) {
      var conversationUuid =
          conversationController.currentConversationUuid.value;
      if (conversationUuid.isEmpty) {
        // new conversation
        //message 的前10个字符，如果message不够10个字符，则全部
        conversationUuid = _newConversation(
            message.substring(0, message.length > 20 ? 20 : message.length),
            message);
      }
      final newMessage = Message(
        conversationId: conversationUuid,
        role: Role.user,
        text: message,
      );
      messageController.addMessage(newMessage);
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

  Widget _buildExpandEmptyListView(List<Prompt> prompts) {
    if (MediaQuery.of(context).size.width > FormFactor.tablet) {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: prompts.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => {_controller.text = (prompts[index].prompt)},
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getRandomColor() as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prompts[index].act,
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
                      prompts[index].prompt,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
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
        itemCount: prompts.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => {_controller.text = prompts[index].prompt},
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getRandomColor() as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    prompts[index].act,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prompts[index].prompt,
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

List<Color?> sMaterialColor = [
  Colors.blue[300],
  Colors.green[300],
  Colors.purple[300],
  Colors.red[300],
  Colors.yellow[300],
  Colors.pink[300],
  Colors.orange[300],
  Colors.teal[300],
  Colors.brown[300],
];
Color? getRandomColor() {
  return sMaterialColor[Random().nextInt(sMaterialColor.length)];
}
