import 'package:mobile/core/models/api_models.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/lumin_api.dart';

class LuminRepository {
  LuminRepository(this.api);

  final LuminApi api;

  Future<ApiResult> get me => api.me();

  Future<ApiResult> updateMe(Map<String, dynamic> body) => api.updateMe(body);

  Future<RepositoryResult<HomeSummaryModel>> homeSummary() async {
    final response = await api.home();
    return RepositoryResult(response, response.ok ? HomeSummaryModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<ProfileSummaryModel>> profileSummary() async {
    final response = await api.profile();
    return RepositoryResult(response, response.ok ? ProfileSummaryModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<List<LanguageModel>>> languages() async {
    final response = await api.languages();
    return RepositoryResult(response, response.ok ? _list(response, LanguageModel.fromJson) : null);
  }

  Future<RepositoryResult<List<CategoryModel>>> categories() async {
    final response = await api.categories();
    return RepositoryResult(response, response.ok ? _list(response, CategoryModel.fromJson) : null);
  }

  Future<RepositoryResult<SettingsModel>> settings() async {
    final response = await api.settings();
    return RepositoryResult(response, response.ok ? SettingsModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<List<UserLanguageProgressModel>>> languagesProgress() async {
    final response = await api.languagesProgress();
    return RepositoryResult(response, response.ok ? _list(response, UserLanguageProgressModel.fromJson) : null);
  }

  Future<RepositoryResult<UserLanguageProgressModel>> languageProgress(int languageId) async {
    final response = await api.languageProgress(languageId);
    return RepositoryResult(response, response.ok ? UserLanguageProgressModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<List<CategoryProgressModel>>> categoryProgress() async {
    final response = await api.categoryProgress();
    return RepositoryResult(response, response.ok ? _list(response, CategoryProgressModel.fromJson) : null);
  }

  Future<RepositoryResult<List<AvatarModel>>> avatars() async {
    final response = await api.avatars();
    return RepositoryResult(response, response.ok ? _list(response, AvatarModel.fromJson) : null);
  }

  Future<RepositoryResult<StudySessionModel>> session(int sessionId) async {
    final response = await api.session(sessionId);
    return RepositoryResult(response, response.ok ? StudySessionModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<ExerciseModel>> currentExercise(int sessionId) async {
    final response = await api.currentExercise(sessionId);
    return RepositoryResult(response, response.ok ? ExerciseModel.fromJson(response.map) : null);
  }

  Future<RepositoryResult<ApiPage<UserWordModel>>> words({
    bool? saved,
    String? level,
    int? categoryId,
    int? languageId,
    String? search,
    bool? onlyPracticed,
    bool? onlyWeak,
    int page = 0,
    int size = 20,
  }) async {
    final response = await api.words(
      saved: saved,
      level: level,
      categoryId: categoryId,
      languageId: languageId,
      search: search,
      onlyPracticed: onlyPracticed,
      onlyWeak: onlyWeak,
      page: page,
      size: size,
    );
    return RepositoryResult(
      response,
      response.ok ? ApiPage.fromJson(response.map, UserWordModel.fromJson) : null,
    );
  }

  Future<RepositoryResult<List<PlacementQuestionModel>>> placementQuestions(int languageId) async {
    final response = await api.placementQuestions(languageId);
    return RepositoryResult(response, response.ok ? _list(response, PlacementQuestionModel.fromJson) : null);
  }

  Future<RepositoryResult<PlacementTestResultModel>> submitPlacement(int languageId, List<Map<String, dynamic>> answers) async {
    final response = await api.submitPlacement(languageId, answers);
    return RepositoryResult(response, response.ok ? PlacementTestResultModel.fromJson(response.map) : null);
  }

  List<T> _list<T>(ApiResult response, T Function(Map<String, dynamic>) parser) {
    return response.list.whereType<Map>().map((item) => parser(Map<String, dynamic>.from(item))).toList();
  }
}

class RepositoryResult<T> {
  const RepositoryResult(this.response, this.data);

  final ApiResult response;
  final T? data;

  bool get ok => response.ok;

  String get error => response.error;
}
