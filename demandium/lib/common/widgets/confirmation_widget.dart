import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class ConfirmationWidget extends StatelessWidget {
  final String? icon;
  final double iconSize;
  final Icon? iconWidget;
  final String? title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Color? yesButtonColor;
  final Function()? onYesPressed;
  final String? noButtonText;
  final String? yesButtonText;
  final Color? noTextColor;
  final Color? yesTextColor;
  final Color? noButtonColor;
  final Widget? customButton;
  final Widget? widget;
  final Function () ? onNoPressed;
  final bool isLoading;
  final double? buttonFontSize;
  const ConfirmationWidget({super.key,  this.icon, this.iconSize = 50, this.title,  this.subtitle,  this.onYesPressed, this.onNoPressed, this.yesButtonColor=const Color(0xFFF24646),
    this.isLoading=false, this.iconWidget, this.noTextColor, this.yesTextColor, this.noButtonColor, this.noButtonText, this.yesButtonText, this.customButton, this.widget, this.buttonFontSize, this.subtitleWidget});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius :  BorderRadius.only(
          topLeft: const Radius.circular(Dimensions.paddingSizeDefault),
          topRight : const Radius.circular(Dimensions.paddingSizeDefault),
          bottomLeft: ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
          bottomRight:  ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
        ),
      ),
      child: SizedBox(width: Dimensions.webMaxWidth / 2.5, child: Padding(
        padding: const EdgeInsets.symmetric( horizontal : Dimensions.paddingSizeLarge),
        child:  widget ??  Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
            height: 4, width: 50, decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(50),
          )),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: iconWidget ?? Image.asset(icon!, width: iconSize,height: iconSize, fit: BoxFit.fitHeight,),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Text(
              title!.tr, textAlign: TextAlign.center,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
          ) : const SizedBox(),

          (subtitle!=null) ? Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(subtitle!.tr,
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          ) : Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: subtitleWidget ?? const SizedBox(height: Dimensions.paddingSizeDefault,),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          customButton ?? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(child: TextButton(
              onPressed: () =>  onNoPressed != null ? onNoPressed!() : Get.back(),
              style: TextButton.styleFrom(
                backgroundColor: noButtonColor ??  Theme.of(context).hintColor.withValues(alpha: 0.15),
                minimumSize: const Size(Dimensions.webMaxWidth, 45),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text( noButtonText?.tr ?? 'no'.tr, textAlign: TextAlign.center,
                style: robotoMedium.copyWith(color: noTextColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: buttonFontSize ?? Dimensions.fontSizeDefault,
                ),
              ),
            )),

            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(
              child:  CustomButton(
                backgroundColor : yesButtonColor,
                textColor: yesTextColor,
                buttonText: yesButtonText?.tr ?? 'yes'.tr,
                onPressed: () =>  onYesPressed != null ? onYesPressed!() : Get.back(),
                radius: Dimensions.radiusSmall, height: 45,
                fontSize: buttonFontSize ?? Dimensions.fontSizeDefault,

              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),

          ]),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge)

        ]),
      )),
    );
  }
}