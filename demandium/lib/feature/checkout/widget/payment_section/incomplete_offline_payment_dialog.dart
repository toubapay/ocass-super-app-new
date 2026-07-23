import 'package:demandium/feature/checkout/widget/payment_section/payment_dialog.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class IncompleteOfflinePaymentDialog extends StatefulWidget {
  final BookingDetailsContent? booking;
  const IncompleteOfflinePaymentDialog({super.key, this.booking});

  @override
  State<IncompleteOfflinePaymentDialog> createState() => _IncompleteOfflinePaymentDialogState();
}

class _IncompleteOfflinePaymentDialogState extends State<IncompleteOfflinePaymentDialog> {

  @override
  void initState() {
    super.initState();
    Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: false);
  }

  @override
  Widget build(BuildContext context) {



    double? bookingAmount = widget.booking?.totalBookingAmount;
    double? dueAmount;
    bool isPartialPayment = widget.booking?.partialPayments !=null && (widget.booking?.partialPayments?.isNotEmpty ?? false);

    if(isPartialPayment){
      widget.booking?.partialPayments?.forEach((element){
        if(element.paidWith == "wallet"){
          dueAmount = element.dueAmount ?? 0;
        }
      });
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius :BorderRadius.only(
          topLeft: const Radius.circular(Dimensions.paddingSizeDefault),
          topRight : const Radius.circular(Dimensions.paddingSizeDefault),
          bottomLeft: ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
          bottomRight:  ResponsiveHelper.isDesktop(context) ?  const Radius.circular(Dimensions.paddingSizeDefault) : Radius.zero,
        ),
      ),
      child: SizedBox(width: Dimensions.webMaxWidth / 2.5, child: Stack(
        clipBehavior: Clip.none,
        children: [

          Padding(
            padding: const EdgeInsets.symmetric( horizontal : Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                child: Text( "your_payment_was_incomplete".tr, textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),

               Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                   color: Theme.of(context).hintColor.withValues(alpha: 0.05)
                 ),
                 padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),

                 child: Row(children: [
                   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Text('booking_id'.tr, style: robotoLight,),
                     const SizedBox(height: Dimensions.paddingSizeTine,),
                     Text('#${widget.booking?.readableId ?? ""}', style: robotoMedium,),
                   ]),

                   const SizedBox(width: Dimensions.paddingSizeSmall),

                   Expanded(child: Column(crossAxisAlignment: isPartialPayment ? CrossAxisAlignment.center :CrossAxisAlignment.end, children: [
                     Text('amount'.tr, style: robotoLight,),
                     const SizedBox(height: Dimensions.paddingSizeTine,),
                     Directionality(
                       textDirection: TextDirection.ltr,
                       child:  Text(PriceConverter.convertPrice( bookingAmount ?? 0), style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis,),
                     ),
                   ])),

                   if(isPartialPayment) const SizedBox(width: Dimensions.paddingSizeSmall),

                   if(isPartialPayment) Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                     Text('due_amount'.tr, style: robotoLight,),
                     const SizedBox(height: Dimensions.paddingSizeTine,),
                     Text(PriceConverter.convertPrice(dueAmount ?? 0), style: robotoMedium,),
                   ]),
                 ]),

               ),

               Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text("your_payment_was_incomplete_please_pay".tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                  textAlign: TextAlign.center,
                ),
              ) ,

              const SizedBox(height: Dimensions.paddingSizeDefault),



              CustomButton(
                buttonText:  'confirm_payment_now'.tr,
                onPressed: () {
                  Get.back();
                 if(ResponsiveHelper.isDesktop(context)){
                   Get.dialog( Center(child: PaymentDialog(booking: widget.booking,)));
                 }else{
                   showModalBottomSheet(context: context,
                     builder: (_){
                       return  PaymentDialog(booking: widget.booking,);
                     },
                     backgroundColor: Colors.transparent,
                     isScrollControlled: true,
                   );
                 }
                },
                radius: Dimensions.radiusSeven, height: 45,
                fontSize:  Dimensions.fontSizeDefault,

              ),

              const SizedBox(height : Dimensions.paddingSizeLarge),
              TextButton(
                onPressed: ()  async  {
                  Get.back();
                  Get.dialog(const CustomLoader(), barrierDismissible: false);

                  await  Get.find<CheckOutController>().switchPaymentMethod(bookingId: widget.booking?.id ?? "", paymentMethod: "cash_after_service");

                  Get.back();
                },
                style: TextButton.styleFrom(
                  backgroundColor:   Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  minimumSize: const Size(Dimensions.webMaxWidth, 45),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                ),
                child: Text(  'switch_to_cas'.tr, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(color:  Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize:  Dimensions.fontSizeDefault,
                  ),
                ),
              ),

              const SizedBox(height : Dimensions.paddingSizeEight),

              TextButton(
                onPressed: () async {
                  Get.back();
                  Get.dialog(const CustomLoader(), barrierDismissible: false);
                  if(widget.booking?.isRepeatBooking == 1 ){
                    await Get.find<BookingDetailsController>().subBookingCancel(subBookingId: widget.booking?.id ?? "");
                  }else{
                    await  Get.find<BookingDetailsController>().bookingCancel(bookingId: widget.booking?.id ?? "");
                  }
                  Get.back();
                },
                style: TextButton.styleFrom(
                  backgroundColor:   Colors.transparent,
                  minimumSize: const Size(Dimensions.webMaxWidth, 45),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSeven)),
                ),
                child: Text(  'cancel_booking'.tr, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(color:  Theme.of(context).colorScheme.error,
                    fontSize:  Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              if(!ResponsiveHelper.isDesktop(context)) const SizedBox(width: Dimensions.paddingSizeLarge),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge)

            ]),
          ),

          Positioned(
            top: 10,
            right: 0,
            child: InkWell(
              onTap: ()=> Get.back() ,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.4)
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeTine),
                child: const Icon(Icons.close, size: 18, color: Colors.white,),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
