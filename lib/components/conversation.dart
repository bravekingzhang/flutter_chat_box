import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/controller/conversation.dart';
import 'package:flutter_chatgpt/controller/message.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/utils/package.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

class ConversationWindow extends StatefulWidget {
  const ConversationWindow({super.key});

  @override
  State<ConversationWindow> createState() => _ConversationWindowState();
}

class _ConversationWindowState extends State<ConversationWindow> {
  bool _isObscure = true;
  String version = '1.0.0';
  @override
  void initState() {
    super.initState();
    getAppVersion().then((value) => setState(() {
          version = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(border: Border(right: BorderSide(width: .3))),
      constraints: const BoxConstraints(maxWidth: 300),
      child: GetX<ConversationController>(builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.conversationList.isEmpty
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
                      itemCount: controller.conversationList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            _tapConversation(index);
                          },
                          selected: controller.currentConversationUuid.value ==
                              controller.conversationList[index].uuid,
                          leading: const Icon(Icons.chat),
                          title: Text(controller.conversationList[index].name),
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
                    label: Text(AppLocalizations.of(context)!.newConversation),
                    icon: const Icon(Icons.add_box),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    label: Text("Version：$version"),
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
        );
      }),
    );
  }

  void _showConversationDetail(BuildContext context, int index) {
    final ConversationController controller = Get.find();
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
        controller.deleteConversation(index);
      } else if (value == "rename") {
        _renameConversation(context, index);
      }
    });
  }

  void _showNewConversationDialog(BuildContext context) {
    ConversationController controller = Get.find();
    controller.setCurrentConversationUuid("");
  }

  void _renameConversation(BuildContext context, int index) {
    final ConversationController conversationController = Get.find();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        controller.text = conversationController.conversationList[index].name;
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
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                conversationController.renameConversation(Conversation(
                  name: controller.text,
                  description: "",
                  uuid: conversationController.conversationList[index].uuid,
                ));
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
    ConversationController controller = Get.find();

    String conversationUUid = controller.conversationList[index].uuid;
    controller.currentConversationUuid(conversationUUid);
    MessageController controllerMessage = Get.find();
    controllerMessage.loadAllMessages(conversationUUid);
  }

  void _showSetting(BuildContext context) {
    final TextEditingController controllerApiKey = TextEditingController();
    final TextEditingController controllerProxy = TextEditingController();
    final TextEditingController controllerGlmBaseUrl = TextEditingController();
    final SettingsController settingsController = Get.find();
    List<Widget> chatGlMModelSettings(StateSetter setState) => [
          const SizedBox(
            height: 28,
          ),
          TextFormField(
            controller: controllerGlmBaseUrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.gmlBaseUrl,
              hintText: AppLocalizations.of(context)!.gmlBaseUrl,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            autovalidateMode: AutovalidateMode.always,
            maxLines: 1,
            onEditingComplete: () {
              settingsController.setGlmBaseUrl(controllerGlmBaseUrl.text);
            },
            onFieldSubmitted: (value) {
              settingsController.setGlmBaseUrl(controllerGlmBaseUrl.text);
            },
          ),
        ];
    List<Widget> openAiModelSettings(StateSetter setState) => [
          const SizedBox(
            height: 28,
          ),
          TextFormField(
            controller: controllerApiKey,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.enterKey,
              hintText: AppLocalizations.of(context)!.enterKeyTips,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            onEditingComplete: () {
              settingsController.setOpenAiKey(controllerApiKey.text);
            },
            onFieldSubmitted: (value) {
              settingsController.setOpenAiKey(controllerApiKey.text);
            },
            obscureText: _isObscure,
          ),
          const SizedBox(
            height: 28,
          ),
          DropdownButtonFormField(
            value: settingsController.openAiBaseUrl.value,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.setProxyUrlTips,
              hintText: AppLocalizations.of(context)!.setProxyUrlTips,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            items: <String>[
              'https://api.openai-proxy.com',
              'https://inkcast.com',
              'https://api.openai.com'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue == null) return;
              settingsController.setOpenAiBaseUrl(newValue);
            },
          ),
          const SizedBox(
            height: 28,
          ),
          DropdownButtonFormField(
              value: settingsController.gptModel.value,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.gptModel,
                hintText: AppLocalizations.of(context)!.gptModel,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              items: <String>[
                'gpt-3.5-turbo',
                'gpt-3.5-turbo-0301',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                settingsController.setGptModel(newValue);
              }),
        ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SettingsController settingsController = Get.find();
        controllerApiKey.text = settingsController.openAiKey.value;
        controllerProxy.text = settingsController.openAiBaseUrl.value;
        controllerGlmBaseUrl.text = settingsController.glmBaseUrl.value;
        return StatefulBuilder(builder: (context, setState) {
          var children = [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.theme),
                Switch(
                  value: Get.theme.brightness == Brightness.dark,
                  onChanged: (value) {
                    settingsController.switchTheme();
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
                  value: settingsController.locale.value.languageCode == 'zh',
                  onChanged: (value) {
                    settingsController.switchLocale();
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
                Text(AppLocalizations.of(context)!.useStreamApi),
                Switch(
                  value: settingsController.useStream.value,
                  onChanged: (value) {
                    settingsController.setUseStream(value);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 28,
            ),
            DropdownButtonFormField(
              value: settingsController.llm.value,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.llmHint,
                hintText: AppLocalizations.of(context)!.llmHint,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              items: <String>['OpenAI', 'ChatGlm', 'IF']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                settingsController.setLlm(newValue);
              },
            ),
          ];
          if (settingsController.llm.value == "OpenAI") {
            children.addAll(openAiModelSettings(setState));
          }
          if (settingsController.llm.value == "ChatGlm") {
            children.addAll(chatGlMModelSettings(setState));
          }
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.settings),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  settingsController.setOpenAiBaseUrl(controllerProxy.text);
                  settingsController.setOpenAiKey(controllerApiKey.text);
                  settingsController.setGlmBaseUrl(controllerGlmBaseUrl.text);
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
