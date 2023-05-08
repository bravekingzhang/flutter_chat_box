import 'dart:convert';
import 'package:flutter_chatgpt/bloc/prompt_bloc.dart';
import 'package:http/http.dart' as http;

const RAW_FILE_URL = "https://raw.githubusercontent.com/";
const MIRRORF_FILE_URL = "https://raw.fgit.ml/";

Future<List<Prompt>> getPrompts() async {
  final List<Prompt> prompts = [];
  final response = await http.get(
    Uri.parse(
        '$MIRRORF_FILE_URL/bravekingzhang/awesome-chatgpt-prompts-zh/main/prompts-zh.json'),
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
