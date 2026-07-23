import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({super.key, required this.img, required this.title, required this.date});
  final String img;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row( crossAxisAlignment: CrossAxisAlignment.end, children: [
      Image.asset(img, height: 15, width: 15, color: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),),
      const SizedBox(width:Dimensions.paddingSizeSmall),
      Expanded(
        child: Row(children: [
          Flexible(
            child: Text(title.tr,
              style: robotoLight.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ), maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(date,
            style: robotoLight.copyWith(
              fontSize: Dimensions.fontSizeSmall,
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
          ),
        ]),
      ),
    ]);
  }
}