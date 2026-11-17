import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/listing/listing_api.dart';
import 'package:sixam_mart/features/listing/widgets/listing_ui.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// Conversations: "Mes ventes" (buyers writing about my listings) and
/// "Mes achats" (sellers I wrote to). Refreshed every 15 seconds.
class ListingMessagesScreen extends StatefulWidget {
  const ListingMessagesScreen({super.key});

  @override
  State<ListingMessagesScreen> createState() => _ListingMessagesScreenState();
}

class _ListingMessagesScreenState extends State<ListingMessagesScreen> {
  late bool _sales = AuthHelper.isLoggedIn();
  List? _chats;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final r = _sales ? await ListingApi.sellerChats() : await ListingApi.buyerChats();
    if (!mounted) return;
    setState(() => _chats = r.statusCode == 200 && r.body is Map ? (r.body['chats'] ?? []) as List : []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(title: 'lst_messages'.tr),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          for (final s in [true, false])
            if (s == false || AuthHelper.isLoggedIn())
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s ? 'lst_my_sales'.tr : 'lst_my_purchases'.tr),
                  selected: _sales == s,
                  showCheckmark: false,
                  selectedColor: LColors.green,
                  backgroundColor: Colors.white,
                  labelStyle: robotoBold.copyWith(fontSize: 13, color: _sales == s ? Colors.white : Colors.black87),
                  shape: const StadiumBorder(),
                  onSelected: (_) {
                    setState(() {
                      _sales = s;
                      _chats = null;
                    });
                    _load();
                  },
                ),
              ),
        ]),
        const SizedBox(height: 12),
        if (_chats == null)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: LColors.green)))
        else if (_chats!.isEmpty)
          ListingEmpty(emoji: '💬', text: _sales ? 'lst_no_sales_chat'.tr : 'lst_no_purchase_chat'.tr)
        else
          for (final c in _chats!) _conversation(c),
      ]),
    );
  }

  Widget _conversation(Map c) {
    final listing = (c['listing'] ?? {}) as Map;
    final mine = c['last_sender'] == (_sales ? 'vendor' : 'buyer');
    final unread = (c['unread'] ?? 0) as int;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await Get.to(() => ListingChatScreen(id: c['id'], seller: _sales));
            _load();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: LColors.line), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 52, height: 52, child: listing['image'] != null ? CustomImage(image: '${listing['image']}', fit: BoxFit.cover) : Container(color: const Color(0xFFEEF3EF))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_sales ? '${c['buyer_name']}' : '${listing['title'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 14)),
                  Text(
                    _sales ? '${listing['title'] ?? ''} · ${listingMoney(listing['price'])}' : listingMoney(listing['price']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: 11.5, color: LColors.muted),
                  ),
                  Text('${mine ? '${'lst_you'.tr} : ' : ''}${c['last_message'] ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: 13)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(listingAgo(DateTime.tryParse('${c['last_message_at']}')), style: robotoRegular.copyWith(fontSize: 11, color: LColors.muted)),
                if (unread > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFE84D4F), borderRadius: BorderRadius.circular(9)),
                    child: Text('$unread', style: robotoBold.copyWith(color: Colors.white, fontSize: 10.5)),
                  ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

/// One conversation, refreshed every 5 seconds.
class ListingChatScreen extends StatefulWidget {
  final int id;
  final bool seller;
  const ListingChatScreen({super.key, required this.id, required this.seller});

  @override
  State<ListingChatScreen> createState() => _ListingChatScreenState();
}

class _ListingChatScreenState extends State<ListingChatScreen> {
  Map? _data;
  String? _error;
  Timer? _timer;
  bool _sending = false;
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = widget.seller ? await ListingApi.sellerChat(widget.id) : await ListingApi.buyerChat(widget.id);
    if (!mounted) return;
    final before = (_data?['messages'] as List?)?.length ?? 0;
    setState(() {
      if (r.statusCode == 200 && r.body is Map) {
        _data = r.body;
      } else {
        _error ??= ListingApi.error(r);
      }
    });
    if (((_data?['messages'] as List?)?.length ?? 0) != before) _toEnd();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final r = widget.seller ? await ListingApi.sellerSend(widget.id, text) : await ListingApi.buyerSend(widget.id, text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (r.statusCode == 200 && r.body is Map) {
        _data = r.body;
        _text.clear();
      }
    });
    _toEnd();
  }

  @override
  Widget build(BuildContext context) {
    final chat = (_data?['chat'] ?? {}) as Map;
    final listing = (chat['listing'] ?? {}) as Map;
    final messages = (_data?['messages'] ?? []) as List;
    final mine = widget.seller ? 'vendor' : 'buyer';
    return Scaffold(
      backgroundColor: LColors.bg,
      appBar: ListingBar(
        title: widget.seller ? '${chat['buyer_name'] ?? ''}' : '${chat['seller_name'] ?? 'lst_seller'.tr}',
        subtitle: listing['title'] == null ? null : '${listing['title']} · ${listingMoney(listing['price'])}',
      ),
      body: Column(children: [
        Expanded(
          child: _data == null
              ? (_error != null ? ListingEmpty(emoji: '🙁', text: _error!) : const Center(child: CircularProgressIndicator(color: LColors.green)))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(14),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i] as Map;
                    final me = m['sender'] == mine;
                    return Align(
                      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 6),
                        decoration: BoxDecoration(
                          color: me ? LColors.green : Colors.white,
                          border: me ? null : Border.all(color: LColors.line),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(me ? 16 : 4),
                            bottomRight: Radius.circular(me ? 4 : 16),
                          ),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${m['body']}', style: robotoRegular.copyWith(fontSize: 14, color: me ? Colors.white : Colors.black87, height: 1.4)),
                          const SizedBox(height: 2),
                          Text(listingAgo(DateTime.tryParse('${m['created_at']}')), style: robotoRegular.copyWith(fontSize: 10, color: me ? Colors.white70 : LColors.muted)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: LColors.line))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'lst_write_message'.tr,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: LColors.green)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: LColors.green),
                onPressed: _sending ? null : _send,
                icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, color: Colors.white),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
