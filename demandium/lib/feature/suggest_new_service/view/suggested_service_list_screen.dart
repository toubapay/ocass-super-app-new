import 'package:demandium/common/widgets/custom_pop_widget.dart';
import 'package:demandium/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/common/widgets/address_selection_drawer.dart';

class SuggestedServiceListScreen extends StatelessWidget {
  const SuggestedServiceListScreen({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      child: Scaffold(
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,

        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        appBar: CustomAppBar(title: 'service_request_list'.tr),
        body: GetBuilder<SuggestServiceController>(
          initState: (_)=>Get.find<SuggestServiceController>().getSuggestedServiceList(1,reload: true),
          builder: (suggestServiceController){
            return FooterBaseView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child:suggestServiceController.suggestedServiceModel!=null?
                Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,children: [
                    if(suggestServiceController.suggestedServiceList.isNotEmpty)
                    Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Row(
                        children: [
                          Text('${'request'.tr} ',style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),),

                          Directionality(textDirection: TextDirection.ltr,
                            child: Text('(${suggestServiceController.suggestedServiceList.length})',style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),)),
                        ],
                      ),
                    ),
                    suggestServiceController.suggestedServiceList.isNotEmpty?
                    ListView.builder(
                      itemCount: suggestServiceController.suggestedServiceList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        return SuggestServiceItemView(suggestedService:suggestServiceController.suggestedServiceList[index]);
                      },):SizedBox(height: Get.height*0.8, child: Center(child: Text(
                        'no_service_request_yet'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),),
                    ),
                  ]),
                ):Center(
                  child: SizedBox(
                      height: ResponsiveHelper.isDesktop(context)?100: Get.height*0.85,
                      child: const Center(child: CircularProgressIndicator())),
                ),
              ),
            );
        }),
      ),
    );
  }
}
