class LanguageModel {
  const LanguageModel({required this.id, required this.name, required this.code, this.createdAt});

  final int id;
  final String name;
  final String code;
  final String? createdAt;

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        id: _int(json['id']),
        name: _string(json['name']),
        code: _string(json['code']),
        createdAt: _nullableString(json['createdAt']),
      );
}

class AvatarModel {
  const AvatarModel({required this.id, required this.name, required this.imageUrl});

  final int id;
  final String name;
  final String imageUrl;

  factory AvatarModel.fromJson(Map<String, dynamic> json) => AvatarModel(
        id: _int(json['id']),
        name: _string(json['name']),
        imageUrl: _string(json['imgUrl']),
      );
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.nativeLanguage,
    this.chosenLanguage,
    this.avatar,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? email;
  final LanguageModel? nativeLanguage;
  final LanguageModel? chosenLanguage;
  final AvatarModel? avatar;
  final String? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _int(json['id']),
        name: _string(json['name']),
        email: _nullableString(json['email']),
        nativeLanguage: _model(json['nativeLanguage'], LanguageModel.fromJson),
        chosenLanguage: _model(json['chosenLanguage'], LanguageModel.fromJson),
        avatar: _model(json['avatar'], AvatarModel.fromJson),
        createdAt: _nullableString(json['createdAt']),
      );
}

class CategoryModel {
  const CategoryModel({required this.id, required this.name, required this.description, this.createdAt});

  final int id;
  final String name;
  final String description;
  final String? createdAt;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: _int(json['id']),
        name: _string(json['name']),
        description: _string(json['description']),
        createdAt: _nullableString(json['createdAt']),
      );
}

class UserWordModel {
  const UserWordModel({
    required this.wordId,
    required this.original,
    required this.translated,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.fromLanguageId,
    required this.fromLanguageCode,
    required this.toLanguageId,
    required this.toLanguageCode,
    required this.isSaved,
    required this.level,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    this.lastPracticed,
    this.createdAt,
  });

  final int wordId;
  final String original;
  final String translated;
  final String description;
  final int? categoryId;
  final String categoryName;
  final int? fromLanguageId;
  final String fromLanguageCode;
  final int? toLanguageId;
  final String toLanguageCode;
  final bool isSaved;
  final String level;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final String? lastPracticed;
  final String? createdAt;

  factory UserWordModel.fromJson(Map<String, dynamic> json) => UserWordModel(
        wordId: _int(json['wordId'] ?? json['id']),
        original: _string(json['original']),
        translated: _string(json['translated']),
        description: _string(json['description']),
        categoryId: _nullableInt(json['categoryId']),
        categoryName: _string(json['categoryName']),
        fromLanguageId: _nullableInt(json['fromLanguageId']),
        fromLanguageCode: _string(json['fromLanguageCode']),
        toLanguageId: _nullableInt(json['toLanguageId']),
        toLanguageCode: _string(json['toLanguageCode']),
        isSaved: json['isSaved'] == true,
        level: _string(json['level']),
        correctAnswers: _int(json['correctAnswers']),
        incorrectAnswers: _int(json['incorrectAnswers']),
        accuracy: _double(json['accuracy']),
        lastPracticed: _nullableString(json['lastPracticed']),
        createdAt: _nullableString(json['createdAt']),
      );
}

class CategoryProgressModel {
  const CategoryProgressModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryDescription,
    required this.totalWords,
    required this.savedWords,
    required this.practicedWords,
    required this.weakWords,
    required this.discoveredWords,
    required this.practicingWords,
    required this.familiarWords,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    this.lastPracticed,
  });

  final int categoryId;
  final String categoryName;
  final String categoryDescription;
  final int totalWords;
  final int savedWords;
  final int practicedWords;
  final int weakWords;
  final int discoveredWords;
  final int practicingWords;
  final int familiarWords;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final String? lastPracticed;

  factory CategoryProgressModel.fromJson(Map<String, dynamic> json) => CategoryProgressModel(
        categoryId: _int(json['categoryId']),
        categoryName: _string(json['categoryName']),
        categoryDescription: _string(json['categoryDescription']),
        totalWords: _int(json['totalWords']),
        savedWords: _int(json['savedWords']),
        practicedWords: _int(json['practicedWords']),
        weakWords: _int(json['weakWords']),
        discoveredWords: _int(json['discoveredWords']),
        practicingWords: _int(json['practicingWords']),
        familiarWords: _int(json['familiarWords']),
        correctAnswers: _int(json['correctAnswers']),
        incorrectAnswers: _int(json['incorrectAnswers']),
        accuracy: _double(json['accuracy']),
        lastPracticed: _nullableString(json['lastPracticed']),
      );
}

class UserLanguageProgressModel {
  const UserLanguageProgressModel({
    required this.language,
    required this.level,
    required this.xp,
    required this.totalSessions,
    required this.totalCorrectAnswers,
    required this.totalIncorrectAnswers,
    required this.placementTestCompleted,
    this.placementTestCompletedAt,
    this.lastPracticed,
  });

  final LanguageModel? language;
  final String level;
  final int xp;
  final int totalSessions;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final bool placementTestCompleted;
  final String? placementTestCompletedAt;
  final String? lastPracticed;

  factory UserLanguageProgressModel.fromJson(Map<String, dynamic> json) => UserLanguageProgressModel(
        language: _model(json['language'], LanguageModel.fromJson),
        level: _string(json['level']),
        xp: _int(json['xp']),
        totalSessions: _int(json['totalSessions']),
        totalCorrectAnswers: _int(json['totalCorrectAnswers']),
        totalIncorrectAnswers: _int(json['totalIncorrectAnswers']),
        placementTestCompleted: json['placementTestCompleted'] == true,
        placementTestCompletedAt: _nullableString(json['placementTestCompletedAt']),
        lastPracticed: _nullableString(json['lastPracticed']),
      );
}

class HomeSummaryModel {
  const HomeSummaryModel({
    required this.userId,
    required this.userName,
    required this.languageId,
    required this.languageName,
    required this.languageCode,
    required this.level,
    required this.xp,
    required this.nextLevelXp,
    required this.levelProgress,
    required this.savedWords,
    required this.practicedWords,
    required this.weakWords,
    required this.recentWords,
    required this.weakRecentWords,
    required this.categoriesProgress,
  });

  final int userId;
  final String userName;
  final int languageId;
  final String languageName;
  final String languageCode;
  final String level;
  final int xp;
  final int nextLevelXp;
  final double levelProgress;
  final int savedWords;
  final int practicedWords;
  final int weakWords;
  final List<UserWordModel> recentWords;
  final List<UserWordModel> weakRecentWords;
  final List<CategoryProgressModel> categoriesProgress;

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) => HomeSummaryModel(
        userId: _int(json['userId']),
        userName: _string(json['userName']),
        languageId: _int(json['languageId']),
        languageName: _string(json['languageName']),
        languageCode: _string(json['languageCode']),
        level: _string(json['level']),
        xp: _int(json['xp']),
        nextLevelXp: _int(json['nextLevelXp']),
        levelProgress: _double(json['levelProgress']),
        savedWords: _int(json['savedWords']),
        practicedWords: _int(json['practicedWords']),
        weakWords: _int(json['weakWords']),
        recentWords: _models(json['recentWords'], UserWordModel.fromJson),
        weakRecentWords: _models(json['weakRecentWords'], UserWordModel.fromJson),
        categoriesProgress: _models(json['categoriesProgress'], CategoryProgressModel.fromJson),
      );
}

class ProfileSummaryModel {
  const ProfileSummaryModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.avatar,
    required this.nativeLanguage,
    required this.chosenLanguage,
    required this.savedWords,
    required this.practicedWords,
    required this.weakWords,
    required this.familiarWords,
    required this.totalSessions,
    required this.totalCorrectAnswers,
    required this.totalIncorrectAnswers,
    required this.accuracy,
    required this.languagesProgress,
    required this.categoriesProgress,
    required this.recentWords,
    this.lastPracticed,
  });

  final int userId;
  final String userName;
  final String email;
  final AvatarModel? avatar;
  final LanguageModel? nativeLanguage;
  final LanguageModel? chosenLanguage;
  final int savedWords;
  final int practicedWords;
  final int weakWords;
  final int familiarWords;
  final int totalSessions;
  final int totalCorrectAnswers;
  final int totalIncorrectAnswers;
  final double accuracy;
  final List<UserLanguageProgressModel> languagesProgress;
  final List<CategoryProgressModel> categoriesProgress;
  final List<UserWordModel> recentWords;
  final String? lastPracticed;

  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) => ProfileSummaryModel(
        userId: _int(json['userId']),
        userName: _string(json['userName']),
        email: _string(json['email']),
        avatar: _model(json['avatar'], AvatarModel.fromJson),
        nativeLanguage: _model(json['nativeLanguage'], LanguageModel.fromJson),
        chosenLanguage: _model(json['chosenLanguage'], LanguageModel.fromJson),
        savedWords: _int(json['savedWords']),
        practicedWords: _int(json['practicedWords']),
        weakWords: _int(json['weakWords']),
        familiarWords: _int(json['familiarWords']),
        totalSessions: _int(json['totalSessions']),
        totalCorrectAnswers: _int(json['totalCorrectAnswers']),
        totalIncorrectAnswers: _int(json['totalIncorrectAnswers']),
        accuracy: _double(json['accuracy']),
        languagesProgress: _models(json['languagesProgress'], UserLanguageProgressModel.fromJson),
        categoriesProgress: _models(json['categoriesProgress'], CategoryProgressModel.fromJson),
        recentWords: _models(json['recentWords'], UserWordModel.fromJson),
        lastPracticed: _nullableString(json['lastPracticed']),
      );
}

class PlacementQuestionModel {
  const PlacementQuestionModel({
    required this.id,
    required this.language,
    required this.level,
    required this.question,
    required this.options,
    this.createdAt,
  });

  final int id;
  final LanguageModel? language;
  final String level;
  final String question;
  final List<String> options;
  final String? createdAt;

  factory PlacementQuestionModel.fromJson(Map<String, dynamic> json) => PlacementQuestionModel(
        id: _int(json['id']),
        language: _model(json['language'], LanguageModel.fromJson),
        level: _string(json['level']),
        question: _string(json['question']),
        options: _strings(json['options']),
        createdAt: _nullableString(json['createdAt']),
      );
}

class PlacementTestResultModel {
  const PlacementTestResultModel({
    required this.userId,
    required this.languageId,
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.placementTestCompleted,
  });

  final int userId;
  final int languageId;
  final String level;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final bool placementTestCompleted;

  factory PlacementTestResultModel.fromJson(Map<String, dynamic> json) => PlacementTestResultModel(
        userId: _int(json['userId']),
        languageId: _int(json['languageId']),
        level: _string(json['level']),
        score: _int(json['score']),
        totalQuestions: _int(json['totalQuestions']),
        accuracy: _double(json['accuracy']),
        placementTestCompleted: json['placementTestCompleted'] == true,
      );
}

class SettingsModel {
  const SettingsModel({
    required this.userId,
    required this.appLanguage,
    required this.notifyDaily,
    required this.notifyReview,
    required this.voice,
    this.updatedAt,
  });

  final int userId;
  final LanguageModel? appLanguage;
  final bool notifyDaily;
  final bool notifyReview;
  final String voice;
  final String? updatedAt;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        userId: _int(json['userId']),
        appLanguage: _model(json['appLanguage'], LanguageModel.fromJson),
        notifyDaily: json['notifyDaily'] == true,
        notifyReview: json['notifyReview'] == true,
        voice: _string(json['voice']),
        updatedAt: _nullableString(json['updatedAt']),
      );
}

class WordModel {
  const WordModel({
    required this.id,
    required this.original,
    required this.translated,
    required this.description,
    required this.category,
    required this.fromLanguage,
    required this.toLanguage,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String original;
  final String translated;
  final String description;
  final CategoryModel? category;
  final LanguageModel? fromLanguage;
  final LanguageModel? toLanguage;
  final String? createdAt;
  final String? updatedAt;

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
        id: _int(json['id'] ?? json['wordId']),
        original: _string(json['original']),
        translated: _string(json['translated']),
        description: _string(json['description']),
        category: _model(json['category'], CategoryModel.fromJson),
        fromLanguage: _model(json['fromLanguage'], LanguageModel.fromJson),
        toLanguage: _model(json['toLanguage'], LanguageModel.fromJson),
        createdAt: _nullableString(json['createdAt']),
        updatedAt: _nullableString(json['updatedAt']),
      );
}

class ExerciseModel {
  const ExerciseModel({
    required this.type,
    required this.id,
    required this.title,
    required this.instruction,
    required this.prompt,
    required this.completed,
    required this.correct,
    required this.language,
    required this.word,
    required this.options,
    required this.requiredWords,
    this.subType,
    this.createdAt,
  });

  final String type;
  final int id;
  final String title;
  final String instruction;
  final String prompt;
  final bool completed;
  final String correct;
  final String? subType;
  final LanguageModel? language;
  final WordModel? word;
  final List<String> options;
  final List<String> requiredWords;
  final String? createdAt;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => ExerciseModel(
        type: _string(json['type']),
        id: _int(json['id']),
        title: _string(json['title']),
        instruction: _string(json['instruction']),
        prompt: _string(json['prompt']),
        completed: json['completed'] == true,
        correct: _string(json['correct']),
        subType: _nullableString(json['subType']),
        language: _model(json['language'], LanguageModel.fromJson),
        word: _model(json['word'], WordModel.fromJson),
        options: _strings(json['options']),
        requiredWords: _strings(json['requiredWords']),
        createdAt: _nullableString(json['createdAt']),
      );
}

class StudySessionModel {
  const StudySessionModel({
    required this.id,
    required this.totalExercises,
    required this.score,
    required this.currentIndex,
    required this.status,
    required this.exercises,
    this.finishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int totalExercises;
  final int score;
  final int currentIndex;
  final String status;
  final List<ExerciseModel> exercises;
  final String? finishedAt;
  final String? createdAt;
  final String? updatedAt;

  factory StudySessionModel.fromJson(Map<String, dynamic> json) => StudySessionModel(
        id: _int(json['id']),
        totalExercises: _int(json['totalExercises']),
        score: _int(json['score']),
        currentIndex: _int(json['currentIndex']),
        status: _string(json['status']),
        exercises: _models(json['exercises'], ExerciseModel.fromJson),
        finishedAt: _nullableString(json['finishedAt']),
        createdAt: _nullableString(json['createdAt']),
        updatedAt: _nullableString(json['updatedAt']),
      );
}

class ApiPage<T> {
  const ApiPage({required this.content, required this.page, required this.size, required this.totalElements, required this.totalPages, required this.first, required this.last, required this.empty});

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool empty;

  factory ApiPage.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) parser) => ApiPage(
        content: _models(json['content'], parser),
        page: _int(json['page']),
        size: _int(json['size']),
        totalElements: _int(json['totalElements']),
        totalPages: _int(json['totalPages']),
        first: json['first'] == true,
        last: json['last'] == true,
        empty: json['empty'] == true,
      );
}

int _int(dynamic value) => value is num ? value.toInt() : 0;
int? _nullableInt(dynamic value) => value is num ? value.toInt() : null;
double _double(dynamic value) => value is num ? value.toDouble() : 0;
String _string(dynamic value) => value?.toString() ?? '';
String? _nullableString(dynamic value) => value is String ? value : null;

T? _model<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value is Map) return parser(Map<String, dynamic>.from(value));
  return null;
}

List<T> _models<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((item) => parser(Map<String, dynamic>.from(item))).toList();
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}
