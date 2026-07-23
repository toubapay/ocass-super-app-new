import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class TextFieldTitle extends StatelessWidget {
  final String title;
  final bool requiredMark;
  const TextFieldTitle({super.key, required this.title, this.requiredMark = false}) ;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall,top: Dimensions.paddingSizeDefault),
      child: RichText(
          text:
          TextSpan(children: <TextSpan>[
            TextSpan(text: title, style: robotoRegular.copyWith(color: Theme.of(Get.context!).textTheme.bodyLarge!.color!.withValues(alpha: 0.9))),
            TextSpan(text: requiredMark?' *':"", style: robotoRegular.copyWith(color: Colors.red)),
          ])),
    );
  }
}
