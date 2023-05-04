import 'dart:convert';
import 'package:flutter_chatgpt/bloc/prompt_bloc.dart';
import 'package:http/http.dart' as http;

Future<List<Prompt>> getPrompts() async {
  final List<Prompt> prompts = [];
  final response = await http.get(
    Uri.parse(
        'https://raw.githubusercontent.com/bravekingzhang/awesome-chatgpt-prompts-zh/main/prompts-zh.json'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    for (var item in jsonResponse) {
      prompts.add(Prompt(item['act'], item['prompt']));
    }
  } else {
    throw Exception('Failed to load prompts');
  }
  return prompts;
}
