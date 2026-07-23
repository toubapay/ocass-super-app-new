import 'package:demandium/util/core_export.dart';

class BookingServiceInfoItem extends StatelessWidget {
  final ItemService bookingContentDetailsItem;
  const BookingServiceInfoItem({super.key,required this.bookingContentDetailsItem}) ;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeExtraSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(bookingContentDetailsItem.service != null)
              SizedBox(
                width: 215,
                child: Text(bookingContentDetailsItem.service!.name!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodyLarge!.color),
                  overflow: TextOverflow.ellipsis,),),
              Text("\$${bookingContentDetailsItem.totalCost}",
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color),),
            ],
          ),
          Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
          Text("${bookingContentDetailsItem.variantKey}",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall,color: Theme.of(context).hintColor),),
          Text("Qty :${bookingContentDetailsItem.quantity}",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall,color: Theme.of(context).hintColor),),
          Gaps.horizontalGapOf(Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}