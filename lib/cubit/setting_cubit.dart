import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/configs/color_schemes.g.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'setting_state.dart';

class UserSettingCubit extends Cubit<UserSettingState> with HydratedMixin {
  UserSettingCubit()
      : super(UserSettingState(lightTheme, const Locale('en'), "",
            "https://api.openai-proxy.com", false, "gpt-3.5-turbo")) {
    hydrate();
  }

  get isDarkMode => state.themeData == darkTheme;

  get isEnglish => state.locale.languageCode == 'en';

  void switchTheme() async {
    emit(UserSettingState(
        state.themeData == lightTheme ? darkTheme : lightTheme,
        state.locale,
        state.key,
        state.baseUrl,
        state.useStream,
        state.gptModel));
  }

  void setKey(String key) {
    emit(UserSettingState(state.themeData, state.locale, key, state.baseUrl,
        state.useStream, state.gptModel));
  }

  void setProxyUrl(String baseUrl) {
    emit(UserSettingState(state.themeData, state.locale, state.key, baseUrl,
        state.useStream, state.gptModel));
  }

  void switchLocale() {
    emit(UserSettingState(
        state.themeData,
        _parseLocale(state.locale.languageCode == 'en' ? 'zh' : 'en'),
        state.key,
        state.baseUrl,
        state.useStream,
        state.gptModel));
  }

  void setUseStream(bool useStream) {
    emit(UserSettingState(state.themeData, state.locale, state.key,
        state.baseUrl, useStream, state.gptModel));
  }

  void setGptModel(String value) {
    emit(UserSettingState(state.themeData, state.locale, state.key,
        state.baseUrl, state.useStream, value));
  }

  @override
  UserSettingState? fromJson(Map<String, dynamic> json) {
    bool isDark = json['user_theme_value'] as bool;
    String locale = json['user_locale_value'] as String;
    String key = json['user_key_value'] as String;
    String baseUrl = json['user_proxy_url_value'] as String;
    bool useStream = json['user_use_stream_value'] as bool;
    String gptModel = json['user_gpt_model_value'] as String;

    return UserSettingState(
        isDark ? darkTheme : lightTheme,
        _parseLocale(locale),
        key,
        baseUrl,
        useStream,
        gptModel.isEmpty ? "gpt-3.5-turbo" : gptModel);
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

  String _locale2Str(Locale locale) {
    return locale.languageCode;
  }

  @override
  Map<String, dynamic>? toJson(UserSettingState state) {
    return {
      'user_theme_value': state.themeData == darkTheme,
      'user_locale_value': _locale2Str(state.locale),
      'user_key_value': state.key,
      'user_proxy_url_value': state.baseUrl,
      'user_use_stream_value': state.useStream,
      'user_gpt_model_value': state.gptModel
    };
  }
}
