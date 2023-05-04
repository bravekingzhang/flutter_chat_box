part of 'setting_cubit.dart';

ThemeData darkTheme =
    ThemeData(useMaterial3: true, colorScheme: darkColorScheme);
ThemeData lightTheme =
    ThemeData(useMaterial3: true, colorScheme: lightColorScheme);

class UserSettingState {
  final ThemeData themeData;
  final String key;
  final Locale locale;
  final String baseUrl;
  final bool useStream;
  final String gptModel;
  final String llm; //大语言模型，OpenAi，ChatGlm，IF
  const UserSettingState(this.themeData, this.locale, this.key, this.baseUrl,
      this.useStream, this.llm, this.gptModel);
}
