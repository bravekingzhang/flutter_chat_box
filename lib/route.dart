import 'package:flutter_chatgpt/pages/home.dart';
import 'package:flutter_chatgpt/pages/second.dart';
import 'package:flutter_chatgpt/pages/setting.dart';
import 'package:get/get.dart';

final routes = [
  GetPage(name: '/', page: () => MyHomePage()),
  GetPage(name: '/second', page: () => const SecondPage()),
  GetPage(name: '/setting', page: () => SettingPage())
];
