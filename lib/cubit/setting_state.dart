part of 'setting_cubit.dart';

ThemeData darkTheme =
    ThemeData(useMaterial3: true, colorScheme: darkColorScheme);
ThemeData lightTheme =
    ThemeData(useMaterial3: true, colorScheme: lightColorScheme);

class UserSettingState {
  final ThemeData themeData;
  final String key;
  final Locale locale;
  const UserSettingState(this.themeData, this.locale, this.key);
}
