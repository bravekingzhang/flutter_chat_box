import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/configs/color_schemes.g.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final openAiKey = "".obs;
  final glmBaseUrl = "".obs;

  final openAiBaseUrl = "https://api.openai-proxy.com".obs;

  final gptModel = "gpt-3.5-turbo".obs;

  final locale = const Locale('zh').obs;

  final useStream = false.obs;

  final llm = "OpenAI".obs;

  static SettingsController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
  }

  void setGlmBaseUrl(String baseUrl) {
    glmBaseUrl.value = baseUrl;
  }

  void setOpenAiKey(String text) {
    openAiKey.value = text;
  }

  void setOpenAiBaseUrl(String baseUrl) {
    openAiBaseUrl.value = baseUrl;
  }

  void setGptModel(String text) {
    gptModel.value = text;
  }

  void switchTheme() {
    Get.changeTheme(Get.isDarkMode ? ThemeData.light() : ThemeData.dark());
  }

  void switchLocale() {
    locale.value =
        _parseLocale(locale.value.languageCode == 'en' ? 'zh' : 'en');
  }

  Locale _parseLocale(String locale) {
    switch (locale) {
      case 'en':
        return const Locale('en');
      case 'zh':
        return const Locale('zh');
      default:
        return const Locale('en');
    }
  }

  void setUseStream(bool value) {
    useStream.value = value;
  }

  void setLlm(String text) {
    llm.value = text;
  }
}
