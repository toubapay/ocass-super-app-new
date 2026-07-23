import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class DeliveryDetailsWidget extends StatelessWidget {
  final AddressModel? deliveryAddress;
  const DeliveryDetailsWidget({super.key, this.deliveryAddress});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _detailsItem(Icons.person_2_outlined, '${deliveryAddress?.contactPersonName}', context),
      _detailsItem(Icons.phone_enabled_outlined, '${deliveryAddress?.contactPersonNumber}', context),
      _detailsItem(Icons.location_on_outlined, '${deliveryAddress?.address}', context),

      const SizedBox(height: Dimensions.paddingSizeSmall),

      Wrap(children: [

        (deliveryAddress?.streetNumber != null && deliveryAddress!.streetNumber!.isNotEmpty) ? RichText(
          text: TextSpan(children: [
            TextSpan(text: '${'street_number'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(
              text: deliveryAddress?.streetNumber ?? '',
              style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ]),
        ) : const SizedBox(),

        (deliveryAddress?.streetNumber != null && deliveryAddress!.streetNumber!.isNotEmpty) ? Container(
          height: 12, width: 1, color: Theme.of(context).hintColor,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        ) : const SizedBox(),

        (deliveryAddress?.house != null && deliveryAddress!.house!.isNotEmpty) ? RichText(
          text: TextSpan(children: [
            TextSpan(text: '${'house'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(
              text: deliveryAddress?.house ?? '',
              style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ]),
        ) : const SizedBox(),

        (deliveryAddress?.house != null && deliveryAddress!.house!.isNotEmpty) ? Container(
          height: 12, width: 1, color: Theme.of(context).hintColor,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        ) : const SizedBox(),

        (deliveryAddress?.floor != null && deliveryAddress!.floor!.isNotEmpty) ? RichText(
          text: TextSpan(children: [
            TextSpan(text: '${'floor'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
            TextSpan(
              text: deliveryAddress?.floor ?? '',
              style: robotoSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ]),
        ) : const SizedBox(),

      ]),
    ]);
  }

  Widget _detailsItem(IconData icon, String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 16,),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Flexible(
            child: Text(
              title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall),
            ),
          ),
        ],
      ),
    );
  }
}
