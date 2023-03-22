import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc//conversation_bloc.dart';
import 'package:flutter_chatgpt/bloc/message_bloc.dart';
import 'package:flutter_chatgpt/cubit/setting_cubit.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/utils/log.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool useTabs = MediaQuery.of(context).size.width < FormFactor.tablet;
    return Scaffold(
      key: _scaffoldKey,
      appBar: useTabs
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.appTitle),
            )
          : null,
      drawer: useTabs
          ? MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => ConversationBloc(),
                ),
                BlocProvider(
                  create: (context) => MessageBloc(),
                ),
              ],
              child: const SideMenu(),
            )
          : null,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConversationBloc(),
          ),
          BlocProvider(
            create: (context) => MessageBloc(),
          ),
        ],
        child: Stack(
          children: [
            useTabs
                ? const ChatWindow()
                : Row(
                    children: const [SideMenu(), ChatWindow()],
                  ),
          ],
        ),
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationBloc>(context)
        .add(const LoadConversationsEvent());
  }

  void _newConversation(String name) {
    BlocProvider.of<ConversationBloc>(context).add(
      AddConversationEvent(
        Conversation(
          name: name,
          uuid: uuid.v4(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
              color: BlocProvider.of<UserSettingCubit>(context)
                  .state
                  .themeData
                  .cardColor,
              border: const Border(right: BorderSide(width: .3))),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            children: [
              state.runtimeType == ConversationInitial
                  ? Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _showNewConversationDialog(context);
                          },
                          child: const Text('Add Conversation'),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              _tapConversation(index);
                            },
                            leading: const Icon(Icons.chat),
                            title: Text(state.conversations[index].name),
                            trailing: Builder(builder: (context) {
                              return IconButton(
                                  onPressed: () {
                                    //显示一个overlay操作
                                    _showConversationDetail(context, index);
                                  },
                                  icon: const Icon(Icons.more_horiz));
                            }),
                          );
                        },
                      ),
                    ),
              const Divider(thickness: .3),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showNewConversationDialog(context);
                      },
                      label: const Text("New Conversation"),
                      icon: const Icon(Icons.add_box),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        EasyLoading.showInfo('还没实现');
                      },
                      label: const Text("Version：1.0.1"),
                      icon: const Icon(Icons.info),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        EasyLoading.showInfo('还没实现');
                      },
                      label: const Text("Settings"),
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showConversationDetail(BuildContext context, int index) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: "delete",
          child: Text("Delete"),
        ),
        const PopupMenuItem(
          value: "rename",
          child: Text("ReName"),
        ),
      ],
    ).then((value) {
      if (value == "delete") {
        BlocProvider.of<ConversationBloc>(context).add(DeleteConversationEvent(
            context.read<ConversationBloc>().state.conversations[index]));
      } else if (value == "rename") {
        _renameConversation(context, index);
        BlocProvider.of<ConversationBloc>(context).add(UpdateConversationEvent(
            context.read<ConversationBloc>().state.conversations[index]));
      }
    });
  }

  void _showNewConversationDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New Conversation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter the role you expect ChatGPT to play',
                  hintText: 'Enter the role you expect ChatGPT to play',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newConversation(controller.text);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _renameConversation(BuildContext context, int index) {
    var outerContext = context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        controller.text = outerContext
            .read<ConversationBloc>()
            .state
            .conversations[index]
            .name;
        return AlertDialog(
          title: const Text("Rename Conversation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter the new name',
                  hintText: 'Enter the new name',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<ConversationBloc>(outerContext).add(
                  UpdateConversationEvent(
                    Conversation(
                      name: controller.text,
                      uuid: outerContext
                          .read<ConversationBloc>()
                          .state
                          .conversations[index]
                          .uuid,
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  _tapConversation(int index) {
    String conversationUUid =
        context.read<ConversationBloc>().state.conversations[index].uuid;
    context
        .read<ConversationBloc>()
        .add(ChooseConversationEvent(conversationUUid));
    context.read<MessageBloc>().add(LoadAllMessagesEvent(conversationUUid));
  }
}

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
