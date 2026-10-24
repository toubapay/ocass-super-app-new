import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/insurance/controllers/insurance_controller.dart';
import 'package:sixam_mart/features/insurance/domain/models/insurance_models.dart';
import 'package:sixam_mart/features/insurance/screens/insurance_payment_screen.dart';
import 'package:sixam_mart/features/insurance/widgets/insurance_format.dart';
import 'package:sixam_mart/features/insurance/widgets/missing_details_sheet.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Every insurer's offer for the request, cheapest first.
class InsuranceQuotesScreen extends StatelessWidget {
  const InsuranceQuotesScreen({super.key});

  Future<void> _buy(InsuranceQuote quote) async {
    final controller = Get.find<InsuranceController>();
    var result = await controller.purchase(quote);

    // The insurer needs details the form did not collect: complete them, then retry once.
    if (result.error?.code == 'missing_vehicle_details' && result.error!.missingFields.isNotEmpty) {
      final completed = await Get.bottomSheet<bool>(
        MissingDetailsSheet(missingFields: result.error!.missingFields),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      if (completed != true) return;
      result = await controller.purchase(quote);
    }

    if (result.error != null) {
      showCustomSnackBar(result.error!.message);
      return;
    }
    if (result.redirectLink == null || result.policyId == null) {
      showCustomSnackBar('ins_something_went_wrong'.tr);
      return;
    }
    Get.to(() => InsurancePaymentScreen(paymentUrl: result.redirectLink!, policyId: result.policyId!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'ins_compare_offers'.tr),
      body: GetBuilder<InsuranceController>(builder: (controller) {
        final result = controller.quoteResult;
        if (result == null) return const SizedBox.shrink();
        final quotes = controller.visibleQuotes;
        final levels = <String, String>{for (final q in result.quotes) q.coverageLevel: q.coverageLevelLabel};

        return Column(children: [
          if (levels.length > 1)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                children: [
                  _FilterChip(label: 'ins_all_levels'.tr, selected: controller.levelFilter == null, onTap: () => controller.setLevelFilter(null)),
                  for (final level in levels.entries)
                    _FilterChip(label: level.value, selected: controller.levelFilter == level.key, onTap: () => controller.setLevelFilter(level.key)),
                ],
              ),
            ),
          if (result.unavailableProviders.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              child: Text('${'ins_unavailable_providers'.tr} ${result.unavailableProviders.join(', ')}',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
          Expanded(
            child: quotes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Text('ins_no_offers'.tr, textAlign: TextAlign.center, style: robotoMedium),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    itemCount: quotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeDefault),
                    itemBuilder: (_, i) => _QuoteCard(
                      quote: quotes[i],
                      isBuying: controller.purchasingQuoteId == quotes[i].id,
                      disabled: controller.purchasingQuoteId != null,
                      onBuy: () => _buy(quotes[i]),
                    ),
                  ),
          ),
        ]);
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final InsuranceQuote quote;
  final bool isBuying;
  final bool disabled;
  final VoidCallback onBuy;
  const _QuoteCard({required this.quote, required this.isBuying, required this.disabled, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: quote.isCheapest ? primary : Theme.of(context).disabledColor.withValues(alpha: 0.3), width: quote.isCheapest ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (quote.isCheapest || quote.isCheapestInLevel)
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
              child: Text(
                quote.isCheapest ? 'ins_cheapest'.tr : '${'ins_best_price'.tr} ${quote.coverageLevelLabel}',
                style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
              ),
            ),
          ),
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: quote.provider.logo != null && quote.provider.logo!.isNotEmpty
                ? CustomImage(image: quote.provider.logo!, width: 44, height: 44, fit: BoxFit.contain, isLogo: true)
                : Container(width: 44, height: 44, color: primary.withValues(alpha: 0.1), child: Icon(Icons.shield_outlined, color: primary)),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(quote.provider.name, style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${quote.productName} · ${quote.coverageLevelLabel}',
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
            ]),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final g in quote.guarantees)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
              child: Text(g.label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
            ),
        ]),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text('ins_price_details'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            children: [
              _line('ins_net_premium'.tr, quote.premiumNet),
              if (quote.fees > 0) _line('ins_fees'.tr, quote.fees),
              if (quote.taxes > 0) _line('ins_taxes'.tr, quote.taxes),
            ],
          ),
        ),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ins_total_to_pay'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              Text(fcfa(quote.totalPremium), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: primary)),
            ]),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: !quote.purchasable || disabled ? null : onBuy,
            child: isBuying
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(quote.purchasable ? 'ins_choose'.tr : 'ins_expired'.tr),
          ),
        ]),
      ]),
    );
  }

  Widget _line(String label, double amount) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
          Text(fcfa(amount), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ]),
      );
}
