import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatgpt/components/markdown_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Markdown extends StatelessWidget {
  final String text;
  const Markdown({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard')),
        );
      },
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: MarkdownBody(data: text, builders: {
            'code': CodeElementBuilder(context),
          }),
        ),
      ),
    );
  }
}
