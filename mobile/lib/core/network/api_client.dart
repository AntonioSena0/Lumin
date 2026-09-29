import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

const apiUnavailableBaseUrl = 'http://localhost:0';

class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  Future<bool>? _refreshInFlight;

  static Future<ApiClient> create(String baseUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final jar = PersistCookieJar(storage: FileStorage('${dir.path}/cookies'));
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(CookieManager(jar));
    return ApiClient._(dio);
  }

  factory ApiClient.unavailable() {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiUnavailableBaseUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    return ApiClient._(dio);
  }

  Future<ApiResult> get(String path, {Map<String, dynamic>? query}) async {
    return _result(
      () => _request(() => _dio.get(path, queryParameters: query)),
    );
  }

  Future<ApiResult> post(String path, [Map<String, dynamic>? body]) async {
    return _result(() => _request(() => _dio.post(path, data: body ?? {})));
  }

  Future<ApiResult> patch(String path, [Map<String, dynamic>? body]) async {
    return _result(() => _request(() => _dio.patch(path, data: body ?? {})));
  }

  Future<ApiResult> put(String path, [Map<String, dynamic>? body]) async {
    return _result(() => _request(() => _dio.put(path, data: body ?? {})));
  }

  Future<int> delete(String path) async {
    try {
      final response = await _request(() => _dio.delete(path));
      return response.statusCode ?? 0;
    } on DioException {
      return 0;
    }
  }

  Future<ApiResult> _result(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return ApiResult(response.statusCode ?? 0, response.data);
    } on DioException {
      return ApiResult(0, {
        'message': 'Não foi possível conectar ao servidor.',
      });
    }
  }

  Future<Uint8List?> bytes(String url) async {
    try {
      final response = await _request(
        () => _dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        ),
      );
      final data = response.data;
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          data != null) {
        return Uint8List.fromList(data);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    final response = await call();
    if (response.statusCode != 401) return response;
    if (_isAuthPath(response)) return response;

    final refreshed = await _refreshOnce();
    if (!refreshed) return response;

    return call();
  }

  bool _isAuthPath(Response<dynamic> response) {
    final path = response.requestOptions.path;
    return path.startsWith('/lumin/auth/');
  }

  Future<bool> _refreshOnce() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _performRefresh();
    _refreshInFlight = future;
    return future;
  }

  Future<bool> _performRefresh() async {
    try {
      final response = await _dio.post('/lumin/auth/refresh');
      return response.statusCode != 401 && response.statusCode != 403;
    } catch (_) {
      return false;
    } finally {
      _refreshInFlight = null;
    }
  }
}

class ApiResult {
  ApiResult(this.status, this.data);

  final int status;
  final dynamic data;

  bool get ok => status >= 200 && status < 300;

  bool get isUnauthorized => status == 401;

  Map<String, dynamic> get map =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : {};

  List<dynamic> get list => data is List ? data as List : [];

  String get error {
    final fields = map['fields'];
    if (fields is List && fields.isNotEmpty) {
      final messages = fields
          .whereType<Map>()
          .map((f) => '${f['message'] ?? ''}'.trim())
          .where((m) => m.isNotEmpty)
          .toList();
      if (messages.isNotEmpty) return messages.join(' ');
    }
    final message = map['message'];
    if (message is String && message.isNotEmpty) return message;
    if (data is String && data.isNotEmpty) return data as String;
    return 'Não foi possível concluir a operação.';
  }
}
