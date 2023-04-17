import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/components/code_wrapper.dart';
import 'package:markdown_widget/markdown_widget.dart';

class Markdown extends StatelessWidget {
  final String text;
  const Markdown({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config =
        isDark ? MarkdownConfig.darkConfig : MarkdownConfig.defaultConfig;
    codeWrapper(child, text) => CodeWrapperWidget(child: child, text: text);
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MarkdownGenerator(
              config: config.copy(configs: [
                isDark
                    ? PreConfig.darkConfig.copy(wrapper: codeWrapper)
                    : const PreConfig().copy(wrapper: codeWrapper)
              ]),
            ).buildWidgets(text)),
      ),
    );
  }
}
