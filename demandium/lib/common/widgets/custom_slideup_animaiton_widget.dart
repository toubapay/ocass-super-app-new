import 'package:flutter/material.dart';

/// A reusable widget that provides a smooth slide-up animation from bottom to top.
/// 
/// This widget wraps any child widget and animates it sliding up from the bottom
/// of the screen when it first appears. Perfect for bottom sheets, modals, or any
/// content that should slide into view.
/// 
/// Example usage:
/// ```dart
/// CustomSlideUpAnimation(
///   duration: Duration(milliseconds: 400),
///   curve: Curves.easeOutCubic,
///   delay: Duration(milliseconds: 100),
///   onAnimationComplete: () => print('Animation done!'),
///   child: YourWidget(),
/// )
/// ```
class CustomSlideUpAnimationWidget extends StatefulWidget {
  /// The widget to be animated
  final Widget child;

  /// Duration of the slide animation
  /// Default: 400 milliseconds
  final Duration duration;

  /// Animation curve for smooth easing
  /// Default: Curves.easeOutCubic
  final Curve curve;

  /// Delay before starting the animation
  /// Default: Duration.zero (no delay)
  final Duration delay;

  /// Callback when animation completes
  final VoidCallback? onAnimationComplete;

  /// Callback when animation starts
  final VoidCallback? onAnimationStart;

  /// Whether to play the animation on widget initialization
  /// Default: true
  final bool autoPlay;

  /// The starting offset factor for the slide animation
  /// 1.0 means start from completely off-screen at the bottom
  /// 0.5 means start from halfway off-screen
  /// Default: 1.0
  final double slideOffset;

  /// Whether to animate opacity along with the slide
  /// Default: false
  final bool fadeIn;

  /// Starting opacity value when fadeIn is enabled
  /// Default: 0.0
  final double fadeStartOpacity;

  /// Ending opacity value when fadeIn is enabled
  /// Default: 1.0
  final double fadeEndOpacity;

  const CustomSlideUpAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
    this.onAnimationComplete,
    this.onAnimationStart,
    this.autoPlay = true,
    this.slideOffset = 1.0,
    this.fadeIn = false,
    this.fadeStartOpacity = 0.0,
    this.fadeEndOpacity = 1.0,
  }) : assert(slideOffset >= 0.0 && slideOffset <= 2.0,
  'slideOffset must be between 0.0 and 2.0'),
        assert(fadeStartOpacity >= 0.0 && fadeStartOpacity <= 1.0,
        'fadeStartOpacity must be between 0.0 and 1.0'),
        assert(fadeEndOpacity >= 0.0 && fadeEndOpacity <= 1.0,
        'fadeEndOpacity must be between 0.0 and 1.0');

  @override
  State<CustomSlideUpAnimationWidget> createState() => CustomSlideUpAnimationWidgetState();
}

class CustomSlideUpAnimationWidgetState extends State<CustomSlideUpAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();

    if (widget.autoPlay) {
      _startAnimation();
    }
  }

  /// Initialize the animation controller and animations
  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.fadeStartOpacity,
      end: widget.fadeEndOpacity,
    ).animate(_slideAnimation);

    _controller.addStatusListener(_handleAnimationStatus);
  }

  /// Handle animation status changes
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      widget.onAnimationStart?.call();
    } else if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    }
  }

  /// Start the animation with optional delay
  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      await _controller.forward();
    }
  }

  /// Public method to manually start the animation
  Future<void> playAnimation() async {
    if (mounted) {
      await _controller.forward(from: 0.0);
    }
  }

  /// Public method to reverse the animation
  Future<void> reverseAnimation() async {
    if (mounted) {
      await _controller.reverse();
    }
  }

  /// Public method to reset the animation
  void resetAnimation() {
    if (mounted) {
      _controller.reset();
    }
  }

  /// Public method to stop the animation
  void stopAnimation() {
    if (mounted) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final offsetY = screenHeight * widget.slideOffset * (1 - _slideAnimation.value);

        Widget animatedChild = Transform.translate(
          offset: Offset(0, offsetY),
          child: child,
        );

        // Apply fade effect if enabled
        if (widget.fadeIn) {
          animatedChild = Opacity(
            opacity: _opacityAnimation.value,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
      child: widget.child,
    );
  }
}

/// Extension to provide easy access to the animation state
extension CustomSlideUpAnimationExtension on BuildContext {
  /// Find the nearest CustomSlideUpAnimationState ancestor
  CustomSlideUpAnimationWidgetState? findSlideUpAnimation() {
    return findAncestorStateOfType<CustomSlideUpAnimationWidgetState>();
  }
}

/// A more advanced variant with staggered animation support
/// 
/// Example usage:
/// ```dart
/// CustomStaggeredSlideUpAnimation(
///   children: [
///     Widget1(),
///     Widget2(),
///     Widget3(),
///   ],
///   staggerDelay: Duration(milliseconds: 100),
/// )
/// ```
class CustomStaggeredSlideUpAnimation extends StatelessWidget {
  /// List of widgets to animate with stagger effect
  final List<Widget> children;

  /// Delay between each child animation
  final Duration staggerDelay;

  /// Duration of each child animation
  final Duration duration;

  /// Animation curve
  final Curve curve;

  /// Initial delay before first animation starts
  final Duration initialDelay;

  /// Whether to animate opacity along with the slide
  final bool fadeIn;

  /// The starting offset factor for the slide animation
  final double slideOffset;

  const CustomStaggeredSlideUpAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.initialDelay = Duration.zero,
    this.fadeIn = false,
    this.slideOffset = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        children.length,
            (index) => CustomSlideUpAnimationWidget(
          duration: duration,
          curve: curve,
          delay: initialDelay + (staggerDelay * index),
          fadeIn: fadeIn,
          slideOffset: slideOffset,
          child: children[index],
        ),
      ),
    );
  }
}

/// Pre-configured animation presets for common use cases
class SlideUpAnimationPresets {
  SlideUpAnimationPresets._();

  /// Quick animation (200ms)
  static const Duration quick = Duration(milliseconds: 200);

  /// Normal animation (400ms)
  static const Duration normal = Duration(milliseconds: 400);

  /// Slow animation (600ms)
  static const Duration slow = Duration(milliseconds: 600);

  /// Spring-like curve
  static const Curve spring = Curves.easeOutBack;

  /// Smooth ease out curve
  static const Curve smooth = Curves.easeOutCubic;

  /// Bouncy curve
  static const Curve bouncy = Curves.bounceOut;

  /// Elastic curve
  static const Curve elastic = Curves.elasticOut;
}