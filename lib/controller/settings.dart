import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/utils/package.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final isObscure = true.obs;
  final openAiKey = "".obs;
  final glmBaseUrl = "".obs;

  final openAiBaseUrl = "https://api.openai-proxy.com".obs;

  final themeMode = ThemeMode.system.obs;

  final gptModel = "gpt-3.5-turbo".obs;

  final locale = const Locale('zh').obs;

  final useStream = true.obs;

  final useWebSearch = false.obs;

  final llm = "OpenAI".obs;

  final version = "1.0.0".obs;

  static SettingsController get to => Get.find();

  @override
  void onInit() async {
    await getThemeModeFromPreferences();
    await getLocaleFromPreferences();
    await getOpenAiBaseUrlFromPreferences();
    await getOpenAiKeyFromPreferences();
    await getGptModelFromPreferences();
    await getUseStreamFromPreferences();
    await initAppVersion();
    super.onInit();
  }

  initAppVersion() async {
    version.value = await getAppVersion();
  }

  void setGlmBaseUrl(String baseUrl) {
    glmBaseUrl.value = baseUrl;
    GetStorage _box = GetStorage();
    _box.write('glmBaseUrl', baseUrl);
  }

  getGlmBaseUrlFromPreferences() async {
    GetStorage _box = GetStorage();
    String baseUrl = _box.read('glmBaseUrl') ?? "https://api.openai-proxy.com";
    setGlmBaseUrl(baseUrl);
  }

  void setOpenAiKey(String text) {
    openAiKey.value = text;
    GetStorage _box = GetStorage();
    _box.write('openAiKey', text);
  }

  getOpenAiKeyFromPreferences() async {
    GetStorage _box = GetStorage();
    String key = _box.read('openAiKey') ?? "";
    setOpenAiKey(key);
  }

  void setOpenAiBaseUrl(String baseUrl) {
    openAiBaseUrl.value = baseUrl;
    update();
    GetStorage _box = GetStorage();
    _box.write('openAiBaseUrl', baseUrl);
  }

  getOpenAiBaseUrlFromPreferences() async {
    GetStorage _box = GetStorage();
    String baseUrl =
        _box.read('openAiBaseUrl') ?? "https://api.openai-proxy.com";
    setOpenAiBaseUrl(baseUrl);
  }

  void setGptModel(String text) {
    gptModel.value = text;
    GetStorage _box = GetStorage();
    _box.write('gptModel', text);
  }

  getGptModelFromPreferences() async {
    GetStorage _box = GetStorage();
    String model = _box.read('gptModel') ?? "gpt-3.5-turbo";
    setGptModel(model);
  }

  void setThemeMode(ThemeMode model) async {
    Get.changeThemeMode(model);
    themeMode.value = model;
    GetStorage _box = GetStorage();
    _box.write('theme', model.toString().split('.')[1]);
  }

  getThemeModeFromPreferences() async {
    ThemeMode themeMode;
    GetStorage _box = GetStorage();
    String themeText = _box.read('theme') ?? 'system';
    try {
      themeMode =
          ThemeMode.values.firstWhere((e) => describeEnum(e) == themeText);
    } catch (e) {
      themeMode = ThemeMode.system;
    }
    setThemeMode(themeMode);
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
        throw Exception('system locale');
    }
  }

  void setUseStream(bool value) {
    useStream.value = value;
    GetStorage _box = GetStorage();
    _box.write('useStream', value);
  }

  getUseStreamFromPreferences() async {
    GetStorage _box = GetStorage();
    bool useStream = _box.read('useStream') ?? true;
    setUseStream(useStream);
  }

  void setUseWebSearch(bool value) {
    useWebSearch.value = value;
    GetStorage _box = GetStorage();
    _box.write('useWebSearch', value);
  }

  void getUseWebSearchFromPreferences() async {
    GetStorage _box = GetStorage();
    bool useWebSearch = _box.read('useWebSearch') ?? false;
    setUseWebSearch(useWebSearch);
  }

  void setLlm(String text) {
    llm.value = text;
  }

  void setLocale(Locale lol) {
    Get.updateLocale(lol);
    locale.value = lol;
    GetStorage _box = GetStorage();
    _box.write('locale', lol.languageCode);
  }

  getLocaleFromPreferences() async {
    Locale locale;
    GetStorage _box = GetStorage();
    String localeText = _box.read('locale') ?? 'zh';
    try {
      locale = _parseLocale(localeText);
    } catch (e) {
      locale = Get.deviceLocale!;
    }
    setLocale(locale);
  }
}
