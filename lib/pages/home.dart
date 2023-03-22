import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc//conversation_bloc.dart';
import 'package:flutter_chatgpt/cubit/setting_cubit.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
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
          ? BlocProvider(
              create: (context) => ConversationBloc(),
              child: const SideMenu(),
            )
          : null,
      body: Stack(
        children: [
          useTabs
              ? const ChatWindow()
              : Row(
                  children: [
                    BlocProvider(
                      create: (context) => ConversationBloc(),
                      child: const SideMenu(),
                    ),
                    const ChatWindow()
                  ],
                ),
        ],
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
  void _newConversation() {
    BlocProvider.of<ConversationBloc>(context).add(AddConversationEvent(
        Conversation(name: "测试测试测试测试测测试测试试", uuid: uuid.v4())));
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
        PopupMenuItem(
          child: Text("Delete"),
          value: "delete",
        ),
        PopupMenuItem(
          child: Text("ReName"),
          value: "rename",
        ),
      ],
    ).then((value) {
      if (value == "delete") {
        BlocProvider.of<ConversationBloc>(context).add(DeleteConversationEvent(
            context.read<ConversationBloc>().state.conversations[index]));
      } else if (value == "rename") {
        BlocProvider.of<ConversationBloc>(context).add(UpdateConversationEvent(
            context.read<ConversationBloc>().state.conversations[index]));
      }
    });
  }

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New Conversation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
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
                _newConversation();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class ChatWindow extends StatefulWidget {
  const ChatWindow({super.key});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
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
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return Text('消息${index + 1}');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey, // 将 GlobalKey 赋值给 Form 组件的 key 属性
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
