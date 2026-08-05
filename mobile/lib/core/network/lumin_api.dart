import 'package:mobile/core/network/api_client.dart';

class LuminApi {
  LuminApi(this.client);

  final ApiClient client;

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required int nativeLanguage,
    required int chosenLanguage,
  }) {
    return client.post('/lumin/users/', {
      'name': name,
      'email': email,
      'password': password,
      'nativeLanguage': nativeLanguage,
      'chosenLanguage': chosenLanguage,
    });
  }

  Future<Map<String, dynamic>> saveWord({
    required int userId,
    required String original,
    required String translated,
    required int categoryId,
  }) {
    return client.post('/lumin/words/save/$userId', {
      'original': original,
      'translated': translated,
      'categoryId': categoryId,
    });
  }

  Future<Map<String, dynamic>> startSession({
    required int userId,
    required int wordId,
  }) {
    return client.post('/lumin/sessions/create/$userId/$wordId', {});
  }

  Future<Map<String, dynamic>> findUser(int userId) {
    return client.get('/lumin/users/$userId');
  }

  Future<Map<String, dynamic>> findSession(int sessionId) {
    return client.get('/lumin/sessions/$sessionId');
  }
}
