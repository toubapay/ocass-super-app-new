import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/naam/naam_voice.dart';
import 'package:sixam_mart/features/naam/widgets/naam_text.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

const _green = Color(0xFF0F6B3E);

/// Naam's portrait: a young Senegalese woman in a pink hijab, framed in Noor gold.
class NaamAvatar extends StatelessWidget {
  final double size;
  const NaamAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => Image.asset('assets/image/naam.webp', width: size, height: size, fit: BoxFit.cover);
}

class _Msg {
  final String role;
  final String text;
  final List<Map<String, dynamic>> sources;
  final String? lang;
  // Buttons under the reply: {type: page | web | maps, url, label, open_now}.
  final List<Map<String, dynamic>> actions;
  _Msg(this.role, this.text, [this.sources = const [], this.lang, this.actions = const []]);

  factory _Msg.fromJson(Map<String, dynamic> j) => _Msg(
        j['role'] == 'assistant' ? 'assistant' : 'user',
        (j['text'] ?? '').toString(),
        ((j['sources'] as List?) ?? []).whereType<Map>().map((s) => Map<String, dynamic>.from(s)).toList(),
        j['lang']?.toString(),
        ((j['actions'] as List?) ?? []).whereType<Map>().map((a) => Map<String, dynamic>.from(a)).toList(),
      );
}

/// Naam, the Noor AI assistant: the admin's greeting, suggested questions,
/// replies with links into the app and web sources, and a hand-off to a person.
class NaamScreen extends StatefulWidget {
  const NaamScreen({super.key});

  @override
  State<NaamScreen> createState() => _NaamScreenState();
}

class _NaamScreenState extends State<NaamScreen> {
  static const _convKey = 'naam_conversation';
  static const _guestKey = 'naam_guest';

  // The server's suggestions are in French; these are the other languages.
  static const _suggestionText = {
    'wo': {
      'Où en est ma commande ?': 'Fan la sama komand tollu ?',
      'Comment recharger mon portefeuille ?': 'Naka laay yokk xaalis ci sama portefeuille ?',
      'Comment télécharger l’appli ?': 'Naka laay yebbi app bi ?',
      'Le Magal de Touba, c’est quand ?': 'Kañ la Màggalu Tuubaa di am ?',
    },
    'ar': {
      'Où en est ma commande ?': 'أين وصل طلبي؟',
      'Comment recharger mon portefeuille ?': 'كيف أشحن محفظتي؟',
      'Comment télécharger l’appli ?': 'كيف أحمّل التطبيق؟',
      'Le Magal de Touba, c’est quand ?': 'متى يكون ماغال طوبى؟',
    },
  };

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  Map<String, dynamic>? _cfg;
  String? _conversationId;
  late final String _guestId;
  bool _busy = false;
  String? _error;
  // Naam reads her replies aloud; the speaker button in the app bar turns it off.
  static const _voiceKey = 'naam_voice_auto';
  late bool _autoVoice = _prefs.getBool(_voiceKey) ?? true;
  Object? _speaking;
  bool get _voiceOn => _cfg?['voice'] == true;

  // Talking to Naam with the phone's speech recognition. The plugin is one
  // shared instance (the search screen uses it too), so its listeners are
  // put back when this screen closes.
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;
  bool _hooked = false;
  String _heard = '';
  stt.SpeechErrorListener? _prevError;
  stt.SpeechStatusListener? _prevStatus;

  ApiClient get _api => Get.find<ApiClient>();
  SharedPreferences get _prefs => Get.find<SharedPreferences>();
  String get _lang => Get.find<LocalizationController>().locale.languageCode;

  @override
  void initState() {
    super.initState();
    _guestId = _prefs.getString(_guestKey) ?? _newGuestId();
    _conversationId = _prefs.getString(_convKey);
    _loadConfig();
    _loadHistory();
  }

  @override
  void dispose() {
    NaamVoice.instance.stop();
    if (_hooked) {
      _speech.cancel();
      _speech.errorListener = _prevError;
      _speech.statusListener = _prevStatus;
    }
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _newGuestId() {
    final r = Random.secure();
    final id = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    _prefs.setString(_guestKey, id);
    return id;
  }

  Future<void> _loadConfig() async {
    final res = await _api.getData(AppConstants.naamConfigUri, query: {'audience': 'customer'}, handleError: false);
    if (!mounted) return;
    setState(() => _cfg = res.statusCode == 200 && res.body is Map ? Map<String, dynamic>.from(res.body) : {'enabled': false});
  }

  Future<void> _loadHistory() async {
    final id = _conversationId;
    if (id == null) return;
    final res = await _api.getData(AppConstants.naamHistoryUri, query: {'conversation_id': id, 'guest_id': _guestId}, handleError: false);
    if (!mounted || res.statusCode != 200 || res.body is! Map) return;
    if (res.body['conversation_id'] == null) {
      _prefs.remove(_convKey);
      setState(() => _conversationId = null);
      return;
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(((res.body['messages'] as List?) ?? []).whereType<Map>().map((m) => _Msg.fromJson(Map<String, dynamic>.from(m))));
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final value = (preset ?? _input.text).trim();
    if (value.isEmpty || _busy) return;
    _input.clear();
    setState(() {
      _error = null;
      _messages.add(_Msg('user', value));
      _busy = true;
    });
    _scrollDown();
    final res = await _api.postData(
      AppConstants.naamChatUri,
      {'message': value, if (_conversationId != null) 'conversation_id': _conversationId, 'guest_id': _guestId, 'audience': 'customer'},
      handleError: false,
      timeout: 90,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.statusCode == 200 && res.body is Map) {
        _conversationId = res.body['conversation_id']?.toString();
        if (_conversationId != null) _prefs.setString(_convKey, _conversationId!);
        _messages.add(_Msg.fromJson({'role': 'assistant', 'text': res.body['reply'], 'lang': res.body['lang'], 'sources': res.body['sources'], 'actions': res.body['actions']}));
        // The customer asked to go to a screen: open it once the reply has been seen.
        final go = _messages.last.actions.where((a) => a['type'] == 'page' && a['open_now'] == true).firstOrNull;
        if (go != null) {
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted) NaamText.open('${go['url']}');
          });
        }
        if (_voiceOn && _autoVoice) _say(_messages.length - 1, res.body['reply'].toString(), res.body['lang']?.toString());
      } else {
        _error = _errorText(res);
      }
    });
    _scrollDown();
  }

  String _errorText(Response res) {
    final errors = res.body is Map ? res.body['errors'] : null;
    if (errors is List && errors.isNotEmpty && errors.first is Map && errors.first['message'] != null) {
      return errors.first['message'].toString();
    }
    return 'naam_error'.tr;
  }

  String get _uiVoiceLang => _lang == 'wo' ? 'wo' : (_lang == 'ar' ? 'ar' : 'fr');

  void _say(Object key, String text, String? lang) {
    if (_speaking == key) {
      NaamVoice.instance.stop();
      return;
    }
    setState(() => _speaking = key);
    NaamVoice.instance.speak(text, lang ?? _uiVoiceLang, useServer: _cfg?['human_voice'] == true || ((lang ?? _uiVoiceLang) == 'wo' && _cfg?['wolof_voice'] == true), onEnd: () {
      if (mounted && _speaking == key) setState(() => _speaking = null);
    });
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stop();
      return;
    }
    if (_busy) return;
    await NaamVoice.instance.stop();
    setState(() => _error = null);
    var ok = false;
    try {
      ok = await _speech.initialize();
    } catch (_) {}
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'naam_mic_unavailable'.tr);
      return;
    }
    if (!_hooked) {
      _prevError = _speech.errorListener;
      _prevStatus = _speech.statusListener;
      _hooked = true;
    }
    _speech.errorListener = (SpeechRecognitionError e) {
      if (!mounted) return;
      final quiet = e.errorMsg.contains('no_match') || e.errorMsg.contains('speech_timeout');
      setState(() {
        _listening = false;
        _error = quiet ? 'naam_mic_no_speech'.tr : 'naam_mic_not_understood'.tr;
      });
    };
    _speech.statusListener = (status) {
      if (status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus) _micDone();
    };
    final locale = await _speechLocale();
    _heard = '';
    setState(() => _listening = true);
    try {
      await _speech.listen(
        onResult: (r) {
          _heard = r.recognizedWords;
          _input.text = _heard;
          _input.selection = TextSelection.collapsed(offset: _input.text.length);
          if (r.finalResult) _micDone();
        },
        localeId: locale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true, listenMode: stt.ListenMode.dictation),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _listening = false;
          _error = 'naam_mic_unavailable'.tr;
        });
      }
    }
  }

  void _micDone() {
    if (!mounted || !_listening) return;
    final text = _heard.trim();
    _heard = '';
    setState(() => _listening = false);
    if (text.isNotEmpty) {
      _input.clear();
      _send(text);
    }
  }

  /// Wolof when the phone can recognise it, else French (Wolof is heard as French).
  Future<String?> _speechLocale() async {
    final want = _lang == 'ar' ? ['ar'] : (_lang == 'wo' ? ['wo', 'fr'] : (_lang == 'en' ? ['en'] : ['fr']));
    try {
      final ids = (await _speech.locales()).map((l) => l.localeId).toList();
      for (final w in want) {
        final exact = ids.where((id) => id.toLowerCase().startsWith(w)).toList();
        if (exact.isEmpty) continue;
        return exact.firstWhere((id) => id.endsWith('SN') || id.endsWith('FR'), orElse: () => exact.first);
      }
    } catch (_) {}
    return _lang == 'ar' ? 'ar_SA' : 'fr_FR';
  }

  void _toggleVoice() {
    setState(() => _autoVoice = !_autoVoice);
    _prefs.setBool(_voiceKey, _autoVoice);
    if (!_autoVoice) NaamVoice.instance.stop();
  }

  /// Naam's buttons: an app screen, a website, or Google Maps directions
  /// (the Google Maps link opens the Maps app, from the current position).
  Widget _actionButtons(List<Map<String, dynamic>> actions) {
    final valid = actions.where((a) {
      final url = '${a['url'] ?? ''}';
      final label = '${a['label'] ?? ''}'.trim();
      if (label.isEmpty) return false;
      return a['type'] == 'page' ? (url.startsWith('/') && !url.startsWith('//')) : (['web', 'maps'].contains(a['type']) && url.startsWith('https://'));
    }).toList();
    if (valid.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final a in valid)
          ElevatedButton.icon(
            onPressed: () => NaamText.open('${a['url']}'),
            icon: Icon(
              a['type'] == 'maps' ? Icons.navigation_rounded : (a['type'] == 'web' ? Icons.open_in_new_rounded : Icons.arrow_forward_rounded),
              size: 16,
            ),
            label: Text('${a['label']}', style: const TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: a['type'] == 'maps' ? const Color(0xFF1A73E8) : _green,
              foregroundColor: a['type'] == 'maps' ? Colors.white : const Color(0xFFF2D27A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: const StadiumBorder(),
            ),
          ),
      ]),
    );
  }

  Widget _listenButton(Object key, String text, String? lang) {
    final on = _speaking == key;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _say(key, text, lang),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: on ? _green : _green.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? _green : _green.withValues(alpha: 0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(on ? Icons.stop_rounded : Icons.volume_up_rounded, size: 15, color: on ? const Color(0xFFF2D27A) : _green),
            const SizedBox(width: 4),
            Text(on ? 'naam_stop'.tr : 'naam_listen'.tr,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? const Color(0xFFF2D27A) : _green)),
          ]),
        ),
      ),
    );
  }

  void _restart() {
    _prefs.remove(_convKey);
    setState(() {
      _conversationId = null;
      _messages.clear();
      _error = null;
    });
  }

  Future<void> _callAdvisor(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent('Bonjour Noor, j’ai besoin d’aide.')}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = _cfg?['enabled'] == true;
    final greetings = _cfg?['greeting'] is Map ? _cfg!['greeting'] as Map : const {};
    final greeting = ((_lang == 'wo' ? greetings['wo'] : greetings['fr']) ?? '').toString().trim();
    final suggestions = ((_cfg?['suggestions'] as List?) ?? []).map((s) => _suggestionText[_lang]?[s] ?? s.toString()).toList();
    final phone = Get.find<SplashController>().configModel?.phone;
    final bodyStyle = TextStyle(fontSize: 15, height: 1.4, color: theme.textTheme.bodyLarge?.color);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(children: [
          const NaamAvatar(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Naam', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              Text('naam_subtitle'.tr, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
        ]),
        actions: [
          if (_voiceOn)
            IconButton(
              icon: Icon(_autoVoice ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              tooltip: _autoVoice ? 'naam_voice_off'.tr : 'naam_voice_on'.tr,
              onPressed: _toggleVoice,
            ),
          if (_messages.isNotEmpty)
            IconButton(icon: const Icon(Icons.restart_alt), tooltip: 'naam_new_conversation'.tr, onPressed: _restart),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              children: [
                if (_cfg != null && !enabled)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.disabledColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Text('naam_unavailable'.tr, style: bodyStyle),
                  )
                else
                  _bubble(context, _Msg('assistant', greeting.isNotEmpty ? greeting : 'naam_greeting'.tr, const [], _uiVoiceLang), bodyStyle, key: 'greeting'),
                for (final (i, m) in _messages.indexed) _bubble(context, m, bodyStyle, key: i),
                if (_busy) _typing(context),
                if (enabled && _messages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, top: 4),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in suggestions)
                        ActionChip(
                          label: Text(s),
                          onPressed: () => _send(s),
                          backgroundColor: theme.cardColor,
                          side: BorderSide(color: _green.withValues(alpha: 0.4)),
                          labelStyle: const TextStyle(color: _green, fontWeight: FontWeight.w600),
                        ),
                    ]),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                if (phone != null && phone.isNotEmpty)
                  Align(
                    child: TextButton.icon(
                      onPressed: () => _callAdvisor(phone),
                      icon: const Icon(Icons.support_agent, size: 18, color: _green),
                      label: Text('naam_talk_to_advisor'.tr, style: const TextStyle(color: _green)),
                    ),
                  ),
              ],
            ),
          ),
          _composer(context, enabled),
        ]),
      ),
    );
  }

  Widget _bubble(BuildContext context, _Msg m, TextStyle style, {Object? key}) {
    final theme = Theme.of(context);
    final mine = m.role == 'user';
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? _green : theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 4),
          bottomRight: Radius.circular(mine ? 4 : 18),
        ),
        boxShadow: mine ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: mine
          ? Text(m.text, style: style.copyWith(color: Colors.white))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              NaamText(text: m.text, style: style),
              if (_voiceOn && key != null) _listenButton(key, m.text, m.lang),
              if (m.actions.isNotEmpty) _actionButtons(m.actions),
              if (m.sources.isNotEmpty) ...[
                const Divider(height: 16),
                for (final s in m.sources)
                  InkWell(
                    onTap: () => NaamText.open((s['url'] ?? '').toString()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(children: [
                        Icon(Icons.public, size: 14, color: theme.primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text((s['title'] ?? s['url'] ?? '').toString(),
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: theme.primaryColor)),
                        ),
                      ]),
                    ),
                  ),
              ],
            ]),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[const NaamAvatar(size: 30), const SizedBox(width: 8)],
          Flexible(child: bubble),
        ],
      ),
    );
  }

  Widget _typing(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          const NaamAvatar(size: 30),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('naam_typing'.tr, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
              const SizedBox(width: 8),
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _green)),
            ]),
          ),
        ]),
      );

  Widget _composer(BuildContext context, bool enabled) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(color: theme.cardColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: TextField(
            controller: _input,
            enabled: _cfg == null || enabled,
            minLines: 1,
            maxLines: 5,
            maxLength: 2000,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: _listening ? 'naam_mic_listening'.tr : 'naam_hint'.tr,
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: theme.disabledColor.withValues(alpha: 0.08),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // The mic replaces send while the box is empty, as in WhatsApp.
        if (enabled && (_listening || _input.text.trim().isEmpty))
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: _listening ? const Color(0xFFC0392B) : _green,
              disabledBackgroundColor: _green.withValues(alpha: 0.35),
            ),
            onPressed: _busy ? null : _toggleMic,
            icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: _listening ? Colors.white : const Color(0xFFF2D27A)),
            tooltip: _listening ? 'naam_mic_stop'.tr : 'naam_mic_talk'.tr,
          )
        else
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: _green, disabledBackgroundColor: _green.withValues(alpha: 0.35)),
            onPressed: _busy || _input.text.trim().isEmpty || (_cfg != null && !enabled) ? null : () => _send(),
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            tooltip: 'naam_send'.tr,
          ),
      ]),
    );
  }
}
