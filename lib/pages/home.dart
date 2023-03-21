import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatgpt/bloc/counter_bloc.dart';
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
    bool useTabs = getFormFactor(context) == ScreenType.Handset;
    return Scaffold(
      key: _scaffoldKey,
      appBar: useTabs
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.appTitle),
            )
          : null,
      drawer: useTabs ? _SideMenu(showPageButtons: false) : null,
      body: BlocBuilder<CounterBloc, CounterState>(
        buildWhen: (previous, current) {
          if (current.states == CounterStates.success) return true;
          if (current.states == CounterStates.loading) {}
          return false;
        },
        builder: (context, state) {
          return useTabs
              ? ChatWindow()
              : Row(
                  children: [_SideMenu, ChatWindow()],
                );
        },
      ),
    );
  }
}

class ChatWindow extends StatefulWidget {
  const ChatWindow({super.key});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  @override
  Widget build(BuildContext context) {
    return const Text("这里显示聊天绘画");
  }
}
