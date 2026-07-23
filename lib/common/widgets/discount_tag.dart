import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DiscountTag extends StatefulWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  final bool? isFloating;
  final bool? fromTaxi;

  const DiscountTag({
    super.key,
    required this.discount,
    required this.discountType,
    this.fromTop = 5,
    this.fontSize,
    this.freeDelivery = false,
    this.inLeft = true,
    this.isFloating = true,
    this.fromTaxi = false,
  });

  @override
  State<DiscountTag> createState() => _DiscountTagState();
}

class _DiscountTagState extends State<DiscountTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // blink
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF17E81E), // light green
      end: const Color(0xFF006006), // dark green
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;

    final bool hasDiscount = (widget.discount ?? 0) > 0;
    final bool hasFreeDelivery = widget.freeDelivery ?? false;
    final bool floating = widget.isFloating ?? true;
    final bool taxi = widget.fromTaxi ?? false;

    if (!(hasDiscount || hasFreeDelivery)) return const SizedBox();

    String text = hasDiscount
        ? '${(isRightSide || widget.discountType == 'percent') ? '' : currencySymbol}'
            '${widget.discount?.toStringAsFixed(0)}'
            '${widget.discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
        : 'free_delivery'.tr;

    return Positioned(
      top: widget.fromTop,
      left: widget.inLeft ? (floating ? Dimensions.paddingSizeSmall : 0) : null,
      right: widget.inLeft ? null : 0,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
              borderRadius: taxi
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      bottomRight: Radius.circular(Dimensions.radiusDefault),
                    )
                  : BorderRadius.horizontal(
                      right: Radius.circular(floating
                          ? Dimensions.radiusLarge
                          : Dimensions.radiusSmall),
                      left: Radius.circular(floating
                          ? Dimensions.radiusLarge
                          : Dimensions.radiusSmall),
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_offer, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  text,
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    fontSize: widget.fontSize ??
                        (ResponsiveHelper.isMobile(context) ? 10 : 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
