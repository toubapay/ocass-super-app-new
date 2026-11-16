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
  // A red tag that swings with a shine every few seconds (as on the web app).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final Animation<double> _angle = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0), weight: 62),
    TweenSequenceItem(tween: Tween(begin: 0, end: -0.16), weight: 6),
    TweenSequenceItem(tween: Tween(begin: -0.16, end: 0.12), weight: 6),
    TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.07), weight: 6),
    TweenSequenceItem(tween: Tween(begin: -0.07, end: 0), weight: 6),
    TweenSequenceItem(tween: ConstantTween(0), weight: 14),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(1), weight: 62),
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.12), weight: 6),
    TweenSequenceItem(tween: ConstantTween(1.12), weight: 6),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 12),
    TweenSequenceItem(tween: ConstantTween(1), weight: 14),
  ]).animate(_controller);

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
        animation: _controller,
        builder: (context, child) {
          final still = MediaQuery.of(context).disableAnimations;
          final t = still ? 0.0 : _controller.value;
          // Shine: a light band sweeping across between 40% and 60% of the loop.
          final shine = ((t - 0.4) / 0.2).clamp(0.0, 1.0);
          return Transform.rotate(
            angle: still ? 0 : _angle.value,
            alignment: Alignment.centerLeft,
            child: Transform.scale(
              scale: still ? 1 : _scale.value,
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFBE123C).withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))],
                  borderRadius: taxi
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusDefault),
                          bottomRight: Radius.circular(Dimensions.radiusDefault),
                        )
                      : BorderRadius.horizontal(
                          right: Radius.circular(floating ? Dimensions.radiusLarge : Dimensions.radiusSmall),
                          left: const Radius.circular(Dimensions.radiusSmall),
                        ),
                ),
                foregroundDecoration: shine > 0 && shine < 1
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-3 + 5 * shine, 0),
                          end: Alignment(-1 + 5 * shine, 0),
                          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0)],
                        ),
                      )
                    : null,
                child: child,
              ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              text,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: widget.fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
