import 'package:flutter/material.dart';

/// A reusable widget that provides a smooth pulse/blink animation effect
/// to highlight newly added or important items in a list.
/// 
/// The animation continuously pulses background and border colors
/// while [shouldAnimate] is true, providing visual feedback to users.
class CustomHighlightAnimationWidget extends StatefulWidget {
  /// The child widget to wrap with the highlight animation
  final Widget child;
  
  /// Whether the animation should be active
  final bool shouldAnimate;
  
  /// Duration of one complete pulse cycle (in and out)
  /// Default is 1500 milliseconds
  final Duration pulseDuration;
  
  /// Background color to pulse to when animating
  /// Uses Color.lerp to interpolate from transparent
  final Color? highlightColor;
  
  /// Border color to pulse to when animating
  final Color? highlightBorderColor;
  
  /// Animation intensity (0.0 to 1.0)
  /// Controls the maximum opacity of highlight colors
  /// Default is 1.0 (full intensity)
  final double intensity;
  
  const CustomHighlightAnimationWidget({
    super.key,
    required this.child,
    required this.shouldAnimate,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.highlightColor,
    this.highlightBorderColor,
    this.intensity = 1.0,
  });

  @override
  State<CustomHighlightAnimationWidget> createState() => _CustomHighlightAnimationWidgetState();
}

class _CustomHighlightAnimationWidgetState extends State<CustomHighlightAnimationWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );
    
    // Create a smooth pulse: 0.0 -> 1.0 -> 0.0
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_animationController);
    
    if (widget.shouldAnimate) {
      _animationController.repeat();
    }
  }
  
  @override
  void didUpdateWidget(CustomHighlightAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation duration if changed
    if (widget.pulseDuration != oldWidget.pulseDuration) {
      _animationController.duration = widget.pulseDuration;
    }
    
    // Start or stop animation based on shouldAnimate flag
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _animationController.repeat();
    } else if (!widget.shouldAnimate && oldWidget.shouldAnimate) {
      _animationController.stop();
      _animationController.reset();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        // Calculate animation value with intensity multiplier
        final animationValue = widget.shouldAnimate 
            ? _pulseAnimation.value * widget.intensity 
            : 0.0;
        
        // Provide animation value to child through inherited widget
        return _HighlightAnimationProvider(
          animationValue: animationValue,
          highlightColor: widget.highlightColor,
          highlightBorderColor: widget.highlightBorderColor,
          child: widget.child,
        );
      },
    );
  }
}

/// Internal inherited widget to provide animation values to child widgets
class _HighlightAnimationProvider extends InheritedWidget {
  final double animationValue;
  final Color? highlightColor;
  final Color? highlightBorderColor;
  
  const _HighlightAnimationProvider({
    required this.animationValue,
    this.highlightColor,
    this.highlightBorderColor,
    required super.child,
  });
  
  static _HighlightAnimationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_HighlightAnimationProvider>();
  }
  
  @override
  bool updateShouldNotify(_HighlightAnimationProvider oldWidget) {
    return animationValue != oldWidget.animationValue ||
           highlightColor != oldWidget.highlightColor ||
           highlightBorderColor != oldWidget.highlightBorderColor;
  }
}

/// Helper extension to easily access highlight animation values
extension HighlightAnimationContext on BuildContext {
  /// Gets the current animation value (0.0 to 1.0) from the nearest
  /// CustomHighlightAnimationWidget ancestor
  double get highlightAnimationValue {
    return _HighlightAnimationProvider.of(this)?.animationValue ?? 0.0;
  }
  
  /// Interpolates a background color with the highlight color
  Color? highlightBackgroundColor(Color? baseColor, Color? targetColor) {
    final provider = _HighlightAnimationProvider.of(this);
    if (provider == null) return baseColor;
    
    final target = targetColor ?? provider.highlightColor ?? Theme.of(this).colorScheme.primary.withValues(alpha: 0.08);
    return Color.lerp(baseColor ?? Colors.transparent, target, provider.animationValue);
  }
  
  /// Interpolates a border color with the highlight border color
  Color? highlightBorderColor(Color? baseColor, Color? targetColor) {
    final provider = _HighlightAnimationProvider.of(this);
    if (provider == null) return baseColor;
    
    final target = targetColor ?? provider.highlightBorderColor ?? Theme.of(this).colorScheme.primary.withValues(alpha: 0.4);
    return Color.lerp(baseColor ?? Colors.grey.withValues(alpha: 0.2), target, provider.animationValue);
  }
}
