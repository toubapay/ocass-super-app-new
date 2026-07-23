import 'package:demandium/feature/checkout/view/offline_payment_screen.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';

class OfflinePaymentDialog extends StatefulWidget {
  final double totalAmount;
  final int index;

  const OfflinePaymentDialog({super.key, required this.totalAmount, required this.index}) ;

  @override
  State<OfflinePaymentDialog> createState() => _OfflinePaymentDialogState();
}

class _OfflinePaymentDialogState extends State<OfflinePaymentDialog> {
  AutoScrollController? scrollController;

  @override
  void initState() {
    scrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
     scrollController!.scrollToIndex(widget.index, preferPosition: AutoScrollPosition.middle);
     scrollController!.highlight(widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<OfflinePaymentModel> offlinePaymentMethodList = Get.find<CheckOutController>().offlinePaymentModelList;
    return Center( child: Container(
        width: Dimensions.webMaxWidth / 2,
        margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: GetBuilder<CheckOutController>(builder: ( checkoutController) {
          return Column(children: [
            Expanded(child: SingleChildScrollView(
              child: Column(children: [
                Text('offline_payment'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Image.asset(Images.offlinePayment, height: 100),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text('pay_your_bill_using_the_info'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color,
                )),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SingleChildScrollView(
                  controller: scrollController, scrollDirection: Axis.horizontal,
                  child: Row(children: offlinePaymentMethodList.map((offline) => AutoScrollTag(
                    controller: scrollController!,
                    key: ValueKey(offlinePaymentMethodList.indexOf(offline)),
                    index: offlinePaymentMethodList.indexOf(offline),
                    child: InkWell(
                      onTap: () async {
                        // checkoutController.changePaymentMethod(offlinePaymentModel: offline);
                        // checkoutController.initializedOfflinePaymentTextField(shouldUpdate: true);
                        // checkoutController.formKey.currentState?.reset();

                        await scrollController!.scrollToIndex(offlinePaymentMethodList.indexOf(offline), preferPosition: AutoScrollPosition.middle);
                        await scrollController!.highlight(offlinePaymentMethodList.indexOf(offline));
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight : 170
                        ),
                        child: Container(
                          width: 315,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          margin: const EdgeInsets.all(Dimensions.paddingSizeEight),
                          decoration: BoxDecoration(
                            color: Theme.of(context).hoverColor,
                            border: Border.all(color: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.1), width: 1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),

                          ),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(offline.methodName ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).secondaryHeaderColor)),

                              if(offline.id == checkoutController.selectedOfflineMethod?.id)
                                Row(mainAxisAlignment: MainAxisAlignment.end,  children: [
                                  Text('pay_on_this_account'.tr, style: robotoRegular.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: Dimensions.fontSizeSmall,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: Dimensions.fontSizeDefault,)
                                ]),

                            ]),
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            if(offline.paymentInformation != null) BillInfoWidget(methodList: offline.paymentInformation),

                          ]),
                        ),
                      ),
                    ),
                  )).toList()),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text( '${'amount'.tr} : ${PriceConverter.convertPrice(widget.totalAmount)}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                if(checkoutController.selectedOfflineMethod?.paymentInformation != null)
                  PaymentInfoWidget(methodInfo: checkoutController.selectedOfflineMethod!.customerInformation),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom,)

              ]),
            )),

            const SizedBox(height: Dimensions.paddingSizeSmall,),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CustomButton(
                buttonText : 'close'.tr, width: 100,height: ResponsiveHelper.isDesktop(context) ? 45 : 40,
                backgroundColor: Theme.of(context).disabledColor,
                onPressed : ()=> Navigator.pop(context),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              CustomButton(
                buttonText : 'submit'.tr,
                width: 130, height: ResponsiveHelper.isDesktop(context) ? 45 : 40, onPressed : (){
                  if(checkoutController.formKey.currentState!.validate()){

                    Map<String,String> value = {};

                    for(int i = 0; i < checkoutController.selectedOfflineMethod!.customerInformation!.length; i++){
                      value.addAll({"${checkoutController.selectedOfflineMethod!.customerInformation?[i].fieldName}" : checkoutController.offlinePaymentInputField[i].text});

                    }
                    checkoutController.offlinePaymentInputFieldValues.add(value);

                    Get.back();
                  }
              },),
            ])
          ]);
        }),
      ),
    );
  }
}


class BillInfoWidget extends StatelessWidget {
  final List<PaymentInformation>? methodList;
  const BillInfoWidget({super.key, required this.methodList}) ;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: methodList!.map((method) => Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(method.title?.replaceAll("_", " ").capitalizeFirst ?? '', style: robotoRegular,overflow: TextOverflow.ellipsis,),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Flexible(child: Text(' :  ${method.data}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),overflow: TextOverflow.ellipsis,)),
      ]),
    )).toList());
  }
}


