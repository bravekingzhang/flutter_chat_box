import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:get/get.dart';

class SettingPage extends GetResponsiveView<SettingsController> {
  SettingPage({super.key});

  @override
  Widget? builder() {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: GetX<SettingsController>(builder: (controller) {
        return ListView(
          children: [
            const Divider(),
            ListTile(
              dense: true,
              title: Text('theme'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: controller.themeMode.value,
              onChanged: (value) {
                controller.setThemeMode(ThemeMode.system);
              },
            ),
            RadioListTile(
              title: const Text('暗黑模式'),
              value: ThemeMode.dark,
              groupValue: controller.themeMode.value,
              onChanged: (value) {
                controller.setThemeMode(ThemeMode.dark);
              },
            ),
            RadioListTile(
              title: const Text('白色模式'),
              value: ThemeMode.light,
              groupValue: controller.themeMode.value,
              onChanged: (value) {
                controller.setThemeMode(ThemeMode.light);
              },
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: Text('language'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            RadioListTile(
              title: const Text('中文'),
              value: 'zh',
              groupValue: controller.locale.value.languageCode,
              onChanged: (value) {
                controller.setLocale(const Locale('zh'));
              },
            ),
            RadioListTile(
              title: const Text('英文'),
              value: 'en',
              groupValue: controller.locale.value.languageCode,
              onChanged: (value) {
                controller.setLocale(const Locale('en'));
              },
            ),
            const Divider(),
            SwitchListTile(
                title: Text(
                  "useStreamApi".tr,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                value: controller.useStream.value,
                onChanged: (value) {
                  controller.setUseStream(value);
                }),
            const Divider(),
            SwitchListTile(
                title: Text(
                  "useWebSearch".tr,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                value: controller.useWebSearch.value,
                onChanged: (value) {
                  controller.setUseWebSearch(value);
                }),
            const Divider(),
            DropdownButtonFormField(
              value: controller.llm.value,
              decoration: InputDecoration(
                labelText: 'llmHint'.tr,
                hintText: 'llmHint'.tr,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).colorScheme.primary),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              items: <String>['OpenAI']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                controller.setLlm(newValue);
              },
            ),
            const Divider(),
            controller.llm.value == "You"
                ? TextFormField(
                    initialValue: controller.youCode.value,
                    decoration: InputDecoration(
                      labelText: 'youCode'.tr,
                      hintText: 'youCodeTips'.tr,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    maxLines: 1,
                    onChanged: (value) => {
                      controller.setYouCode(value),
                    },
                    onEditingComplete: () {},
                    onFieldSubmitted: (value) {
                      controller.setYouCode(value);
                    },
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            controller.llm.value == "OpenAI"
                ? TextFormField(
                    initialValue: controller.openAiKey.value,
                    decoration: InputDecoration(
                      labelText: 'enterKey'.tr,
                      hintText: 'enterKey'.tr,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: controller.isObscure.value
                              ? Colors.grey
                              : Colors.blue,
                        ),
                        onPressed: () {
                          controller.isObscure.value =
                              !controller.isObscure.value;
                        },
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    maxLines: 1,
                    onChanged: (value) => {
                      controller.setOpenAiKey(value),
                      OpenAI.apiKey = value,
                    },
                    onFieldSubmitted: (value) {
                      controller.setOpenAiKey(value);
                    },
                    obscureText: controller.isObscure.value,
                  )
                : const SizedBox(),
            controller.llm.value == "OpenAI"
                ? const SizedBox(
                    height: 20,
                  )
                : const SizedBox(),
            controller.llm.value == "OpenAI" || controller.llm.value == "You"
                ? DropdownButtonFormField(
                    value: controller.openAiBaseUrl.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'setProxyUrlTips'.tr,
                      hintText: 'setProxyUrlTips'.tr,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    items: <String>[
                      'https://api.openai-proxy.com',
                      'https://api.openai.com',
                      'https://api.wgpt.in'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value, // 缩短显示文本
                          overflow: TextOverflow.ellipsis, // 超出长度省略号显示
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue == null) return;
                      controller.setOpenAiBaseUrl(newValue);
                    },
                  )
                : const SizedBox(),
            controller.llm.value == "OpenAI" || controller.llm.value == "You"
                ? const SizedBox(
                    height: 20,
                  )
                : const SizedBox(),
            controller.llm.value == "OpenAI" || controller.llm.value == "You"
                ? DropdownButtonFormField(
                    value: controller.gptModel.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'gptModel'.tr,
                      hintText: 'gptModel'.tr,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(Get.context!).colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    items: <String>[
                      'gpt-3.5-turbo',
                      'gpt-3.5-turbo-16k',
                      'gpt-4',
                      'gpt-4-0314',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue == null) return;
                      controller.setGptModel(newValue);
                    })
                : const SizedBox(),
          ],
        );
      }),
    );
  }
}
