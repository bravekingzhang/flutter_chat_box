import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc//conversation_bloc.dart';
import 'package:flutter_chatgpt/bloc/message_bloc.dart';
import 'package:flutter_chatgpt/components/chat.dart';
import 'package:flutter_chatgpt/components/conversation.dart';
import 'package:flutter_chatgpt/device/form_factor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      drawer: useTabs ? const ConversationWindow() : null,
      body: Stack(
        children: [
          useTabs
              ? const ChatWindow()
              : Row(
                  children: const [ConversationWindow(), ChatWindow()],
                ),
        ],
      ),
    );
  }
}
