import 'package:get/get.dart';

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          "appTitle": "ChatGpt",
          "toSecondPage": "to second page",
          "secondPage": "this is the second Page",
          "countTimes": "current total count is:",
          "noConversationTips":
              "There seems to be no session, click on the left to create one quickly, or simply type prompt to create one",
          "newConversation": "New Conversation",
          "renameConversation": "Rename Conversation",
          "settings": "Settings",
          "theme": "switch theme",
          "language": "switch language",
          "delete": "Delete",
          "reName": "ReName",
          "inputPrompt": "Input your prompt",
          "inputPromptTips": "Input your prompt here",
          "enterKey": "Enter the chatgpt key",
          "enterKeyTips": "Enter the chatgpt key here",
          "setProxyUrl": "Enter the proxy url",
          "setProxyUrlTips": "Select the proxy url here.",
          "ok": "OK",
          "cancel": "Cancel",
          "useStreamApi": "Use Stream API",
          "gptModel": "Select GPT Model",
          "llmHint": "Select LLM Model",
          "gmlBaseUrl": "Please input chatglm base url"
        },
        'zh_CN': {
          "appTitle": "智能助手",
          "toSecondPage": "去到第二页",
          "secondPage": "这里上第二页",
          "countTimes": "当前的数字是：",
          "noConversationTips": "似乎没有会话，点击左侧快速创建一个，或简单地键入提示创建一个",
          "newConversation": "创建新会话",
          "renameConversation": "重命名会话",
          "settings": "设置",
          "theme": "切换主题",
          "language": "切换语言",
          "delete": "删除",
          "reName": "重命名",
          "inputPrompt": "请输入你的 prompt",
          "inputPromptTips": "在这里输入你的 prompt",
          "enterKey": "请输入你的 chatgpt key",
          "enterKeyTips": "请输在这里输入你的 chatgpt key",
          "setProxyUrl": "请输入代理Url",
          "setProxyUrlTips": "请在这里设置代理Url",
          "ok": "确定",
          "cancel": "取消",
          "useStreamApi": "使用流式(Stream) API",
          "gptModel": "选择 GPT Model",
          "llmHint": "选择大语言模型",
          "gmlBaseUrl": "请输入chatglm代理Url"
        }
      };
}
