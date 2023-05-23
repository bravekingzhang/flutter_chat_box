import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/controller/conversation.dart';
import 'package:flutter_chatgpt/controller/message.dart';
import 'package:flutter_chatgpt/controller/prompt.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/pages/unknown.dart';
import 'package:flutter_chatgpt/configs/translations.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_chatgpt/route.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    Get.put(ConversationController());
    Get.put(MessageController());
    Get.put(PromptController());
    return GetMaterialApp(
      initialRoute: '/',
      getPages: routes,
      unknownRoute:
          GetPage(name: '/not_found', page: () => const UnknownRoutePage()),
      theme: FlexThemeData.light(scheme: FlexScheme.ebonyClay),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.ebonyClay),
      themeMode: ThemeMode.system,
      locale: const Locale('zh'),
      translations: MyTranslations(),
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
    );
  }
}
