import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init({String voice = 'FEMALE'}) async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVoice({'name': voice == 'MALE' ? 'en-us-x-tmc-local' : 'en-us-x-iod-local'});
    _ready = true;
  }

  Future<void> speak(String text, {String voice = 'FEMALE'}) async {
    await init(voice: voice);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
