import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/ride/controllers/ride_controller.dart';
import 'package:sixam_mart/features/ride/domain/ride_models.dart';
import 'package:url_launcher/url_launcher.dart';

const _ink = Color(0xFF1C1C1E);
const _yellow = Color(0xFFF5B301);

/// Chat with the driver during the ride (refreshed every 3 s), with quick
/// replies and a call button.
class RideChatScreen extends StatefulWidget {
  final RideTrip trip;
  const RideChatScreen({super.key, required this.trip});

  @override
  State<RideChatScreen> createState() => _RideChatScreenState();
}

class _RideChatScreenState extends State<RideChatScreen> {
  static const _quick = ['ride_chat_coming', 'ride_chat_at_pickup', 'ride_chat_in_front', 'ride_chat_ok'];

  final _text = TextEditingController();
  final _scroll = ScrollController();
  List<RideMessage> _messages = [];
  bool _busy = false;
  Timer? _timer;

  RideController get _c => Get.find<RideController>();

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _c.messages(widget.trip.id);
    if (!mounted || list == null) return;
    final grew = list.length != _messages.length;
    setState(() => _messages = list);
    if (grew) _toEnd();
  }

  void _toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });

  Future<void> _send([String? preset]) async {
    final body = (preset ?? _text.text).trim();
    if (body.isEmpty || _busy) return;
    setState(() => _busy = true);
    final (m, error) = await _c.sendMessage(widget.trip.id, body);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (m != null) {
        _messages = [..._messages, m];
        _text.clear();
      }
    });
    if (error != null) Get.snackbar('', error, snackPosition: SnackPosition.BOTTOM);
    _toEnd();
  }

  String _time(DateTime? t) => t == null ? '' : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final d = widget.trip.driver;
    final open = widget.trip.chatOpen;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d?.name ?? 'ride_your_driver'.tr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          Text([d?.color, d?.vehicle, d?.plate].where((x) => x != null && x.isNotEmpty).join(' · '), style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
        actions: [
          if (d?.phone != null && d!.phone!.isNotEmpty)
            IconButton(
              tooltip: 'ride_call_driver'.tr,
              icon: const CircleAvatar(backgroundColor: Color(0xFF16A34A), child: Icon(Icons.call, color: Colors.white, size: 20)),
              onPressed: () => launchUrl(Uri.parse('tel:${d.phone}')),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('ride_chat_empty'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final me = m.from == 'rider';
                      return Align(
                        alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: me ? _ink : const Color(0xFFF2F2F4),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(me ? 16 : 4),
                              bottomRight: Radius.circular(me ? 4 : 16),
                            ),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.text, style: TextStyle(color: me ? Colors.white : _ink, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${_time(m.at)}${me && m.read ? ' · ${'ride_chat_read'.tr}' : ''}', style: TextStyle(fontSize: 10.5, color: me ? Colors.white70 : Colors.black45)),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
          if (open) ...[
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final q in _quick)
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                      child: ActionChip(label: Text(q.tr), onPressed: _busy ? null : () => _send(q.tr), backgroundColor: Colors.white, shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD4D4D8)))),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'ride_chat_hint'.tr,
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: _yellow, foregroundColor: _ink),
                  onPressed: _busy ? null : () => _send(),
                  icon: const Icon(Icons.send_rounded),
                  tooltip: 'naam_send'.tr,
                ),
              ]),
            ),
          ] else
            Padding(padding: const EdgeInsets.all(16), child: Text('ride_chat_closed'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))),
        ]),
      ),
    );
  }
}
