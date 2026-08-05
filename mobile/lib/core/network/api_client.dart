import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final HttpClient httpClient = HttpClient();

  Future<Map<String, dynamic>> get(String path) async {
    final request = await httpClient.getUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    final response = await request.close();
    return readJson(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final request = await httpClient.postUrl(Uri.parse('$baseUrl$path'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    return readJson(response);
  }

  Future<void> delete(String path) async {
    final request = await httpClient.deleteUrl(Uri.parse('$baseUrl$path'));
    await request.close();
  }

  Future<Map<String, dynamic>> readJson(HttpClientResponse response) async {
    final content = await response.transform(utf8.decoder).join();
    if (content.isEmpty) {
      return {};
    }
    return jsonDecode(content) as Map<String, dynamic>;
  }
}
