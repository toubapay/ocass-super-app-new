import 'package:demandium/util/dimensions.dart';
import 'package:demandium/util/styles.dart';
import 'package:flutter/material.dart';

class WebMidSectionContentItem extends StatelessWidget {
  final String title;
  final String subTitle;
  const WebMidSectionContentItem({super.key, required this.title,required this.subTitle}) ;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, textAlign: TextAlign.start,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          subTitle, textAlign: TextAlign.start,
          style: robotoRegular.copyWith(
              color: Theme.of(context).disabledColor,
              fontSize: Dimensions.fontSizeSmall,
            height: 1.5
          ),
          maxLines: 5, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }
}

