import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/controller/prompt.dart';
import 'package:get/get.dart';

class PromptsView extends GetResponsiveView {
  final List<Prompt> prompts;
  final ValueChanged<String> onPromptClick;

  PromptsView(this.prompts, this.onPromptClick);

  final _scrollController = ScrollController();

  @override
  Widget? desktop() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: prompts.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => {onPromptClick(prompts[index].prompt)},
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
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    prompts[index].prompt,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    maxLines: 5,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget? phone() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: prompts.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => {onPromptClick(prompts[index].prompt)},
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
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
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

List<Color?> sMaterialColor = [
  Colors.blue[300],
  Colors.green[300],
  Colors.purple[300],
  Colors.red[300],
  Colors.pink[300],
  Colors.orange[300],
  Colors.teal[300],
  Colors.brown[300],
];
Color? getRandomColor() {
  return sMaterialColor[Random().nextInt(sMaterialColor.length)];
}
