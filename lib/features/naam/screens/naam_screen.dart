import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/naam/widgets/naam_text.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

const _green = Color(0xFF0F6B3E);
const _gold = Color(0xFFD4AF37);

/// Naam's round "N" badge, green with a gold letter.
class NaamAvatar extends StatelessWidget {
  final double size;
  const NaamAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _green,
          border: Border.all(color: _gold, width: size > 34 ? 2 : 1.5),
        ),
        child: Text('N', style: TextStyle(color: _gold, fontWeight: FontWeight.w800, fontSize: size * 0.46)),
      );
}

class _Msg {
  final String role;
  final String text;
  final List<Map<String, dynamic>> sources;
  _Msg(this.role, this.text, [this.sources = const []]);

  factory _Msg.fromJson(Map<String, dynamic> j) => _Msg(
        j['role'] == 'assistant' ? 'assistant' : 'user',
        (j['text'] ?? '').toString(),
        ((j['sources'] as List?) ?? []).whereType<Map>().map((s) => Map<String, dynamic>.from(s)).toList(),
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
        _messages.add(_Msg.fromJson({'role': 'assistant', 'text': res.body['reply'], 'sources': res.body['sources']}));
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
                  _bubble(context, _Msg('assistant', greeting.isNotEmpty ? greeting : 'naam_greeting'.tr), bodyStyle),
                for (final m in _messages) _bubble(context, m, bodyStyle),
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

  Widget _bubble(BuildContext context, _Msg m, TextStyle style) {
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
              hintText: 'naam_hint'.tr,
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
