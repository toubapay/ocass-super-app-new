import 'package:demandium/util/core_export.dart';

class UnselectedProductWidget extends StatelessWidget {
  const UnselectedProductWidget({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  60 , width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: Center(child: Hero(tag: 'provide_image',
        child: ClipRRect( borderRadius: BorderRadius.circular(Dimensions.radiusExtraMoreLarge),
          child: Image.asset(Images.providerImage,height: 40,width: 40,),
        ),
      )),
    );
  }
}
