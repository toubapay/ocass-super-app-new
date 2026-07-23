import 'package:demandium/common/widgets/custom_image.dart';
import 'package:demandium/util/dimensions.dart';
import 'package:demandium/util/styles.dart';
import 'package:flutter/material.dart';
import 'web_mid_section_content_item.dart';

class WebMidSection extends StatelessWidget {
  final Map<String?,String?>? textContent;
  final String? featureImage;
  const WebMidSection({super.key, required this.textContent, this.featureImage}) ;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(textContent?['web_mid_title'] != null && textContent?['web_mid_title'] != '')Text(
            textContent?['web_mid_title']??"",
            style: robotoBold.copyWith(fontSize: 26,),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                CustomImage(
                  height: Dimensions.featureSectionImageSize,
                  width: Dimensions.featureSectionImageSize,
                  image:featureImage ?? "",
                  fit: BoxFit.fitHeight,
                ),
              const SizedBox(width: Dimensions.paddingSizeExtraMoreLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(textContent!['mid_sub_title_1'] != null && textContent!['mid_sub_description_1'] != null)
                    WebMidSectionContentItem(title:textContent?['mid_sub_title_1']??"",subTitle:textContent?['mid_sub_description_1']??""),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                    if(textContent!['mid_sub_title_2'] != null && textContent!['mid_sub_description_2'] != null)
                      WebMidSectionContentItem(title:textContent?['mid_sub_title_2']??"",subTitle:textContent?['mid_sub_description_2']??""),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                    if(textContent!['mid_sub_title_3'] != null && textContent!['mid_sub_description_3'] != null)
                      WebMidSectionContentItem(title:textContent?['mid_sub_title_3']??"",subTitle:textContent?['mid_sub_description_3']??""),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraMoreLarge),
            ],
          ),
        ],
      ),
    );
  }
}
