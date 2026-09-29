import 'dart:typed_data';

import 'package:mobile/core/network/api_client.dart';

class LuminApi {
  LuminApi(this.client);

  final ApiClient client;

  Future<ApiResult> register({
    required String name,
    required String email,
    required String password,
    required int nativeLanguage,
    required int chosenLanguage,
  }) {
    return client.post('/lumin/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'nativeLanguage': nativeLanguage,
      'chosenLanguage': chosenLanguage,
    });
  }

  Future<ApiResult> login({required String email, required String password}) {
    return client.post('/lumin/auth/login', {'email': email, 'password': password});
  }

  Future<ApiResult> refresh() {
    return client.post('/lumin/auth/refresh');
  }

  Future<ApiResult> logout() {
    return client.post('/lumin/auth/logout');
  }

  Future<ApiResult> verify({required String email, required String code}) {
    return client.post('/lumin/auth/verify', {'email': email, 'code': code});
  }

  Future<ApiResult> resend({required String email}) {
    return client.post('/lumin/auth/resend', {'email': email});
  }

  Future<ApiResult> forgotPassword({required String email}) {
    return client.post('/lumin/auth/password/forgot', {'email': email});
  }

  Future<ApiResult> resetPassword({required String email, required String code, required String newPassword}) {
    return client.post('/lumin/auth/password/reset', {'email': email, 'code': code, 'newPassword': newPassword});
  }

  Future<ApiResult> oauth({required String provider, required String idToken}) {
    return client.post('/lumin/auth/oauth', {'provider': provider, 'idToken': idToken});
  }

  Future<ApiResult> registerOauth({
    required String name,
    required int nativeLanguage,
    required int chosenLanguage,
    required String provider,
    required String idToken,
  }) {
    return client.post('/lumin/auth/register/oauth', {
      'name': name,
      'nativeLanguage': nativeLanguage,
      'chosenLanguage': chosenLanguage,
      'provider': provider,
      'idToken': idToken,
    });
  }

  Future<ApiResult> me() {
    return client.get('/lumin/me');
  }

  Future<ApiResult> updateMe(Map<String, dynamic> body) {
    return client.patch('/lumin/me', body);
  }

  Future<ApiResult> changeAvatar(int avatarId) {
    return client.patch('/lumin/me/change-avatar', {'avatarId': avatarId});
  }

  Future<ApiResult> requestPasswordChange() {
    return client.post('/lumin/me/password/request');
  }

  Future<ApiResult> confirmPasswordChange({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return client.post('/lumin/me/password/confirm', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<ApiResult> home() {
    return client.get('/lumin/me/home');
  }

  Future<ApiResult> profile() {
    return client.get('/lumin/me/profile');
  }

  Future<ApiResult> settings() {
    return client.get('/lumin/me/settings');
  }

  Future<ApiResult> updateSettings(Map<String, dynamic> body) {
    return client.patch('/lumin/me/settings', body);
  }

  Future<ApiResult> progress() {
    return client.get('/lumin/me/progress');
  }

  Future<ApiResult> placementQuestions(int languageId) {
    return client.get('/lumin/me/placement-test/languages/$languageId');
  }

  Future<ApiResult> submitPlacement(int languageId, List<Map<String, dynamic>> answers) {
    return client.post('/lumin/me/placement-test/languages/$languageId/submit', {'answers': answers});
  }

  Future<ApiResult> words({
    bool? saved,
    String? level,
    int? categoryId,
    int? languageId,
    String? search,
    bool? onlyPracticed,
    bool? onlyWeak,
    int page = 0,
    int size = 20,
  }) {
    return client.get('/lumin/me/words', query: {
      'saved': ?saved,
      'level': ?level,
      'categoryId': ?categoryId,
      'languageId': ?languageId,
      'search': ?search,
      'onlyPracticed': ?onlyPracticed,
      'onlyWeak': ?onlyWeak,
      'page': page,
      'size': size,
    });
  }

  Future<ApiResult> saveWord({required String original, required String translated, required int categoryId}) {
    return client.post('/lumin/me/words/save', {
      'original': original,
      'translated': translated,
      'categoryId': categoryId,
    });
  }

  Future<ApiResult> unsaveWord(int wordId) {
    return client.patch('/lumin/me/words/$wordId/unsave');
  }

  Future<ApiResult> findUserWord(int wordId) {
    return client.get('/lumin/me/words/$wordId');
  }

  Future<ApiResult> catalogWords({int page = 0, int size = 20}) {
    return client.get('/lumin/words', query: {'page': page, 'size': size});
  }

  Future<ApiResult> searchWords({required int languageId, required String q, int page = 0, int size = 20}) {
    return client.get(
      '/lumin/words/$languageId/search=${Uri.encodeComponent(q)}',
      query: {'page': page, 'size': size},
    );
  }

  Future<ApiResult> categoryWords({required int categoryId, int page = 0, int size = 40}) {
    return client.get('/lumin/me/words', query: {
      'categoryId': categoryId,
      'page': page,
      'size': size,
    });
  }

  Future<ApiResult> startSession(int wordId) {
    return client.post('/lumin/me/sessions/create/$wordId');
  }

  Future<ApiResult> session(int sessionId) {
    return client.get('/lumin/me/sessions/$sessionId');
  }

  Future<ApiResult> languagesProgress() {
    return client.get('/lumin/me/progress');
  }

  Future<ApiResult> languageProgress(int languageId) {
    return client.get('/lumin/me/progress/$languageId');
  }

  Future<ApiResult> createLanguageProgress(int languageId) {
    return client.post('/lumin/me/progress/$languageId');
  }

  Future<ApiResult> categoryProgress() {
    return client.get('/lumin/me/categories/progress');
  }

  Future<ApiResult> users({int page = 0, int size = 20}) {
    return client.get('/lumin/users', query: {'page': page, 'size': size});
  }

  Future<ApiResult> user(int id) {
    return client.get('/lumin/users/$id');
  }

  Future<ApiResult> deleteMe() async {
    final status = await client.delete('/lumin/me');
    return ApiResult(status, null);
  }

  Future<ApiResult> putMe(Map<String, dynamic> body) {
    return client.put('/lumin/me', body);
  }

  Future<ApiResult> category(int id) {
    return client.get('/lumin/categories/$id');
  }

  Future<ApiResult> language(int id) {
    return client.get('/lumin/languages/$id');
  }

  Future<ApiResult> avatar(int id) {
    return client.get('/lumin/avatars/$id');
  }

  Future<ApiResult> catalogWord(int wordId) {
    return client.get('/lumin/words/$wordId');
  }

  Future<ApiResult> sessions({int page = 0, int size = 20}) {
    return client.get('/lumin/me/sessions', query: {'page': page, 'size': size});
  }

  Future<Uint8List?> assetBytes(String url) async {
    final bytes = await client.bytes(url);
    return bytes;
  }

  Future<ApiResult> currentExercise(int sessionId) {
    return client.get('/lumin/me/sessions/$sessionId/current-exercise');
  }

  Future<ApiResult> answerExercise(int sessionId, int exerciseId, String answer) {
    return client.post('/lumin/me/sessions/$sessionId/exercises/$exerciseId/answer', {'answer': answer});
  }

  Future<ApiResult> finishSession(int sessionId) {
    return client.patch('/lumin/me/sessions/finish/$sessionId');
  }

  Future<ApiResult> languages() {
    return client.get('/lumin/languages/');
  }

  Future<ApiResult> categories() {
    return client.get('/lumin/categories/');
  }

  Future<ApiResult> avatars() {
    return client.get('/lumin/avatars/');
  }
}
