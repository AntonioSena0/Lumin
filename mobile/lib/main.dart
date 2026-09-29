import 'package:flutter/material.dart';
import 'package:mobile/app/lumin_app.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/lumin_api.dart';
import 'package:mobile/core/repositories/lumin_repository.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://lumin-api.up.railway.app',
);

String resolveAssetUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '$apiBaseUrl$path';
}

late final LuminApi luminApi;
late final LuminRepository luminRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final client = await ApiClient.create(apiBaseUrl);
    luminApi = LuminApi(client);
    luminRepository = LuminRepository(luminApi);
  } catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack, library: 'lumin bootstrap'),
    );
    luminApi = LuminApi(ApiClient.unavailable());
    luminRepository = LuminRepository(luminApi);
  }
  runApp(const LuminApp());
}
