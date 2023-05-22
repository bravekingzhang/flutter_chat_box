import 'package:flutter_chatgpt/utils/prompt.dart';
import 'package:get/get.dart';

class PromptController extends GetxController {
  final prompts = <Prompt>[].obs;

  @override
  void onInit() async {
    prompts.value = await getPrompts();
    super.onInit();
  }
}

class Prompt {
  final String act;
  final String prompt;

  Prompt(this.act, this.prompt);
}
