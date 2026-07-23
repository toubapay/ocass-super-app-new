import 'package:demandium/util/core_export.dart';
import 'package:demandium/feature/suggest_new_service/model/suggest_service_model.dart';
import 'package:get/get.dart';

class SuggestServiceItemView extends StatelessWidget {
  final SuggestedService suggestedService;

  const SuggestServiceItemView({super.key, required this.suggestedService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeEight,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            suggestedService.category?.image != null
                ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        child: CustomImage(
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          image: suggestedService.category?.imageFullPath ?? "",
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: Text(
                            suggestedService.category?.name ?? "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeTine,
              ),
              child: Text(
                "suggested_service".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).secondaryHeaderColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            Text(
              suggestedService.serviceName ?? "",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeTine,
              ),
              child: Text(
                "description".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(
                    context,
                  ).secondaryHeaderColor.withValues(alpha: 0.8),
                ),
              ),
            ),

            Text(
              suggestedService.serviceDescription ?? "",
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
              maxLines: 100,
              overflow: TextOverflow.ellipsis,
              textAlign: Get.find<ServiceLocalizationController>().isLtr
                  ? TextAlign.justify
                  : TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
