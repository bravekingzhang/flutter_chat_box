import 'package:flutter_chatgpt/pages/home.dart';
import 'package:flutter_chatgpt/pages/second.dart';
import 'package:get/get.dart';

final routes = [
  GetPage(name: '/', page: () => const MyHomePage()),
  GetPage(name: '/second', page: () => const SecondPage()),
];
