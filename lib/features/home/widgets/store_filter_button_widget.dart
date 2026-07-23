import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class StoreFilterButtonWidget extends StatelessWidget {
  const StoreFilterButtonWidget({super.key, this.isSelected, this.onTap, required this.buttonText});

  final bool? isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: isSelected == true 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected == true 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).disabledColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isSelected == true 
                  ? Colors.white 
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}
