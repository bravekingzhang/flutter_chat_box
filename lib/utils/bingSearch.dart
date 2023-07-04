import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

Future<void> main() async {
  String query = "今天星期几";
  String result = await fetchAndParse(query);
  print(result);
}

Future<String> fetchAndParse(String query) async {
  try {
    String content = "# Web search result:\n ";
    String refer = "# Web reference:\n";
    String finalResult = "";

    final url =
        'https://www.bing.com/search?form=QBRE&q=${Uri.encodeComponent(query)}&cc=CN&wppersonalization=off';
    print(url);
    final response = await http.get(Uri.parse(url));
    final html = response.body;

    List<Map<String, String>> summaries = [];

    var document = parser.parse(html);
    var results = document.querySelectorAll("#b_results .b_algo");

    results.take(5).forEach((element) {
      var linkElement = element.querySelector("a");
      var href = linkElement?.attributes['href'];
      var title = linkElement?.text;
      var abstractElement = element.querySelector(".b_caption p");
      var abstract = abstractElement?.text?.trim();

      if (href != null && title != null && abstract != null) {
        summaries.add({'href': href, 'title': title, 'abstract': abstract});
      }
    });

    if (summaries.isEmpty) {
      return query;
    }

    summaries.forEach((result) {
      content = '$content${result['abstract']} \n';
      refer = '$refer[${result['title']}](${result['href']})\n';
    });

    finalResult =
        '$content\n$refer\n# Instructions: \nUsing the provided web search results, write a comprehensive reply to the given query. Make sure to cite results using [[number](URL)] notation after the reference. If the provided search results refer to multiple subjects with the same name, write separate answers for each subject，your answer should markdown link list all given Web Reference at the end.\nQuery: $query\n Reply in 中文';

    return finalResult;
  } catch (error) {
    print("An error occurred: $error");
    return query;
  }
}
