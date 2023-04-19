import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc/conversation_bloc.dart';
import 'package:flutter_chatgpt/bloc/message_bloc.dart';
import 'package:flutter_chatgpt/cubit/setting_cubit.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConversationWindow extends StatefulWidget {
  const ConversationWindow({super.key});

  @override
  State<ConversationWindow> createState() => _ConversationWindowState();
}

class _ConversationWindowState extends State<ConversationWindow> {
  bool _isObscure = true;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationBloc>(context)
        .add(const LoadConversationsEvent());
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              state.runtimeType == ConversationInitial ||
                      state.conversations.isEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.noConversationTips,
                            textAlign: TextAlign.center,
                          ),
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
                            selected: state.currentConversationUuid ==
                                state.conversations[index].uuid,
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
                      label:
                          Text(AppLocalizations.of(context)!.newConversation),
                      icon: const Icon(Icons.add_box),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      label: const Text("Version：1.0.1"),
                      icon: const Icon(Icons.info),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _showSetting(context);
                      },
                      label: Text(AppLocalizations.of(context)!.settings),
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
        Overlay.of(context).context.findRenderObject() as RenderBox;
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
          value: "delete",
          child: Text(AppLocalizations.of(context)!.delete),
        ),
        PopupMenuItem(
          value: "rename",
          child: Text(AppLocalizations.of(context)!.reName),
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
    context.read<ConversationBloc>().add(const ChooseConversationEvent(""));
    context
        .read<MessageBloc>()
        .add(const LoadAllMessagesEvent("new conversation"));
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
                ),
                autovalidateMode: AutovalidateMode.always,
                maxLines: null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _showSecondConfirm();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<ConversationBloc>(outerContext).add(
                  UpdateConversationEvent(
                    Conversation(
                      name: controller.text,
                      description: "",
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

  _showSecondConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure to cancel?"),
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

  void _showSetting(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controllerApiKey = TextEditingController();
        controllerApiKey.text =
            BlocProvider.of<UserSettingCubit>(context).state.key;
        final TextEditingController controllerProxy = TextEditingController();
        controllerProxy.text =
            BlocProvider.of<UserSettingCubit>(context).state.baseUrl;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.settings),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.theme),
                      Switch(
                        value: BlocProvider.of<UserSettingCubit>(context)
                                .state
                                .themeData ==
                            darkTheme,
                        onChanged: (value) {
                          BlocProvider.of<UserSettingCubit>(context)
                              .switchTheme();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.language),
                      Switch(
                        value: BlocProvider.of<UserSettingCubit>(context)
                                .state
                                .locale
                                .languageCode ==
                            'zh',
                        onChanged: (value) {
                          BlocProvider.of<UserSettingCubit>(context)
                              .switchLocale();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  TextFormField(
                    controller: controllerProxy,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.setProxyUrl,
                      hintText: AppLocalizations.of(context)!.setProxyUrlTips,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    maxLines: null,
                    onChanged: (value) {
                      BlocProvider.of<UserSettingCubit>(context)
                          .setProxyUrl(value);
                    },
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  TextFormField(
                    controller: controllerApiKey,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.enterKey,
                      hintText: AppLocalizations.of(context)!.enterKeyTips,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: _isObscure ? Colors.grey : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    maxLines: 1,
                    onChanged: (value) {
                      BlocProvider.of<UserSettingCubit>(context).setKey(value);
                    },
                    obscureText: _isObscure,
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.useStreamApi),
                      Switch(
                        value: BlocProvider.of<UserSettingCubit>(context)
                            .state
                            .useStream,
                        onChanged: (value) {
                          BlocProvider.of<UserSettingCubit>(context)
                              .setUseStream(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Wrap(
                    children: [
                      Text(AppLocalizations.of(context)!.gptModel),
                      DropdownButton<String>(
                        value: BlocProvider.of<UserSettingCubit>(context)
                            .state
                            .gptModel,
                        onChanged: (String? newValue) {
                          BlocProvider.of<UserSettingCubit>(context)
                              .setGptModel(newValue!);
                        },
                        items: <String>[
                          'gpt-3.5-turbo',
                          'gpt-3.5-turbo-0301',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          );
        });
      },
    );
  }
}
