import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/components/chat.dart';
import 'package:flutter_chatgpt/components/conversation.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool useTabs = MediaQuery.of(context).size.width < FormFactor.tablet;
    return Scaffold(
      appBar: useTabs
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.appTitle),
            )
          : null,
      drawer: useTabs ? const ConversationWindow() : null,
      body: Stack(
        children: [
          useTabs
              ? Row(
                  children: const [
                    ChatWindow(),
                  ],
                )
              : Row(
                  children: const [ConversationWindow(), ChatWindow()],
                ),
        ],
      ),
    );
  }
}
