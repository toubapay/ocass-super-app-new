import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sixam_mart/util/app_constants.dart';

/// Naam's voice. French (and Arabic, English) is read by the phone's own
/// voice (flutter_tts). Wolof comes from the admin's Wolof voice server
/// through /api/v1/naam/speak when one is set; otherwise the French voice
/// reads it, since no phone has a Wolof voice.
class NaamVoice {
  NaamVoice._();
  static final NaamVoice instance = NaamVoice._();

  static const _locales = {'fr': 'fr-FR', 'wo': 'fr-FR', 'ar': 'ar-SA', 'en': 'en-US'};
  // Female voices first, as Naam is a young woman.
  static final _preferred = RegExp(r'amélie|amelie|audrey|aurélie|aurelie|marie|julie|céline|celine|hortense|denise|léa|virginie|female|femme|fr-fr-x-fr[ac]', caseSensitive: false);

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  VoidCallback? _onEnd;
  int _run = 0;
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    await _tts.awaitSpeakCompletion(false);
    await _tts.setSpeechRate(defaultTargetPlatform == TargetPlatform.iOS ? 0.5 : 0.48);
    await _tts.setPitch(1.05);
    _tts.setCompletionHandler(_finish);
    _tts.setCancelHandler(_finish);
    _tts.setErrorHandler((_) => _finish());
    _player.onPlayerComplete.listen((_) => _finish());
  }

  void _finish() {
    final cb = _onEnd;
    _onEnd = null;
    cb?.call();
  }

  /// The text to read: no markdown, links read by their label, no URLs.
  static String speakable(String text) {
    var t = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1)!);
    t = t.replaceAll(RegExp(r'https?://\S+'), '');
    t = t.replaceAll(RegExp(r'\*\*|__|`|#+\s'), '');
    t = t.replaceAll(RegExp(r'^\s*([-*•]|\d+[.)])\s+', multiLine: true), '');
    t = t.trim();
    return t.length > 1500 ? t.substring(0, 1500) : t;
  }

  Future<void> stop() async {
    _run++;
    await _player.stop();
    await _tts.stop();
    _finish();
  }

  /// Reads a reply aloud; `onEnd` runs once when it finishes or is stopped.
  Future<void> speak(String text, String lang, {bool useServer = false, VoidCallback? onEnd}) async {
    await _init();
    await stop();
    final run = _run;
    _onEnd = onEnd;
    final clean = speakable(text);
    if (clean.isEmpty) return _finish();

    if (lang == 'wo' && useServer) {
      try {
        final res = await http
            .post(Uri.parse('${AppConstants.baseUrl}${AppConstants.naamSpeakUri}'),
                headers: {'Content-Type': 'application/json', 'Accept': 'audio/*, application/json'},
                body: jsonEncode({'text': clean, 'lang': 'wo'}))
            .timeout(const Duration(seconds: 45));
        if (run != _run) return;
        final type = res.headers['content-type'] ?? '';
        if (res.statusCode == 200 && type.startsWith('audio/')) {
          final ext = type.contains('mpeg') || type.contains('mp3') ? 'mp3' : (type.contains('ogg') ? 'ogg' : 'wav');
          final file = File('${(await getTemporaryDirectory()).path}/naam_voice.$ext');
          await file.writeAsBytes(res.bodyBytes, flush: true);
          if (run != _run) return;
          await _player.play(DeviceFileSource(file.path));
          return;
        }
      } catch (_) {
        // Falls back to the phone's voice.
      }
      if (run != _run) return;
    }

    final locale = _locales[lang] ?? 'fr-FR';
    await _tts.setLanguage(locale);
    try {
      final voices = (await _tts.getVoices as List?) ?? const [];
      final matching = voices
          .whereType<Map>()
          .where((v) => (v['locale'] ?? '').toString().toLowerCase().replaceAll('_', '-').startsWith(locale.substring(0, 2)))
          .toList();
      final voice = matching.firstWhere((v) => _preferred.hasMatch('${v['name']}'), orElse: () => matching.isNotEmpty ? matching.first : {});
      if (voice.isNotEmpty) {
        await _tts.setVoice({'name': '${voice['name']}', 'locale': '${voice['locale']}'});
      }
    } catch (_) {
      // Keep the default voice for the language.
    }
    if (run != _run) return;
    await _tts.speak(clean);
  }
}
