import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sixam_mart/features/mobile_money/domain/models/mobile_money_models.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// XOF has no minor unit: whole francs with a space as thousands separator.
String fcfa(num amount) => '${NumberFormat('#,##0', 'en_US').format(amount.round()).replaceAll(',', ' ')} F CFA';

/// Masked 4-digit secret code field.
class PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  const PinField({super.key, required this.controller, required this.label, this.autofocus = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Text(label, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 6),
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            onChanged: onChanged,
            style: robotoBold.copyWith(fontSize: 26, letterSpacing: 18),
            decoration: const InputDecoration(counterText: '', hintText: '••••'),
          ),
        ),
      ]),
    );
  }
}

class TransferTile extends StatelessWidget {
  final MoneyTransfer transfer;
  const TransferTile({super.key, required this.transfer});

  @override
  Widget build(BuildContext context) {
    final sent = transfer.sent;
    final color = sent ? const Color(0xFF6B4F05) : const Color(0xFF136C34);
    final date = transfer.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(transfer.createdAt!) : '';
    final details = [
      date,
      transfer.reference,
      if (sent && transfer.fee > 0) '${'mm_fee'.tr} ${fcfa(transfer.fee)}',
      if (transfer.status == 'reversed') 'mm_reversed'.tr,
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(sent ? Icons.north_east : Icons.south_west, size: 18, color: color),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(
                  '${sent ? 'mm_to'.tr : 'mm_from'.tr} ${transfer.counterpart?.name ?? '-'}',
                  style: robotoBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${transfer.walletAmount >= 0 ? '+' : '−'} ${fcfa(transfer.walletAmount.abs())}',
                style: robotoBold.copyWith(color: transfer.walletAmount >= 0 ? const Color(0xFF1E8E3E) : const Color(0xFFD93025)),
              ),
            ]),
            const SizedBox(height: 2),
            Text(details, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            if (transfer.note != null && transfer.note!.isNotEmpty)
              Text('« ${transfer.note} »', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
          ]),
        ),
      ]),
    );
  }
}
