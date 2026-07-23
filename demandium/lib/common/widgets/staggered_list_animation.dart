import 'package:flutter/material.dart';

/// A reusable widget that provides staggered fade-in and slide-up animation
/// for list items. Typically used to animate list items when they first appear.
/// 
/// Example usage:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return StaggeredListAnimation(
///       index: index,
///       child: YourListItemWidget(),
///     );
///   },
/// )
/// ```
class StaggeredListAnimation extends StatelessWidget {
  /// The child widget to be animated
  final Widget child;
  
  /// The index of the item in the list (used for staggered delay)
  final int index;
  
  /// Animation controller from parent widget
  final AnimationController controller;
  
  /// Duration of the animation for each item (default: 300ms)
  final Duration duration;
  
  /// Delay multiplier between items (default: 100ms per item)
  final double staggerDelay;
  
  /// The curve to use for the animation (default: easeOutCubic)
  final Curve curve;
  
  /// Vertical offset for slide animation (default: 0.2)
  final double slideOffset;

  const StaggeredListAnimation({
    super.key,
    required this.child,
    required this.index,
    required this.controller,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = 0.1,
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate staggered interval for this item
    final double start = (index * staggerDelay).clamp(0.0, 1.0);
    final double end = (start + 0.5).clamp(0.0, 1.0);
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: curve),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, slideOffset),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A wrapper widget that provides an AnimationController for staggered list animations.
/// This eliminates the need to manage AnimationController in parent widgets.
/// 
/// Example usage:
/// ```dart
/// StaggeredListAnimationWrapper(
///   duration: Duration(milliseconds: 600),
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) {
///       return StaggeredListAnimationItem(
///         index: index,
///         child: YourListItemWidget(),
///       );
///     },
///   ),
/// )
/// ```
class StaggeredListAnimationWrapper extends StatefulWidget {
  /// The child widget (typically a ListView)
  final Widget child;
  
  /// Total duration for the animation controller
  final Duration duration;
  
  /// Whether to auto-start the animation (default: true)
  final bool autoPlay;

  const StaggeredListAnimationWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.autoPlay = true,
  });

  @override
  State<StaggeredListAnimationWrapper> createState() => _StaggeredListAnimationWrapperState();
}

class _StaggeredListAnimationWrapperState extends State<StaggeredListAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    if (widget.autoPlay) {
      // Start animation after a small delay to ensure widgets are built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimationControllerProvider(
      controller: _controller,
      child: widget.child,
    );
  }
}

/// InheritedWidget to provide AnimationController to descendants
class _AnimationControllerProvider extends InheritedWidget {
  final AnimationController controller;

  const _AnimationControllerProvider({
    required this.controller,
    required super.child,
  });

  static AnimationController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AnimationControllerProvider>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(_AnimationControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// A convenient widget to use inside StaggeredListAnimationWrapper.
/// Automatically gets the AnimationController from the wrapper.
/// 
/// Example usage:
/// ```dart
/// StaggeredListAnimationWrapper(
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) {
///       return StaggeredListAnimationItem(
///         index: index,
///         child: YourListItemWidget(),
///       );
///     },
///   ),
/// )
/// ```
class StaggeredListAnimationItem extends StatelessWidget {
  final Widget child;
  final int index;
  final double staggerDelay;
  final Curve curve;
  final double slideOffset;

  const StaggeredListAnimationItem({
    super.key,
    required this.child,
    required this.index,
    this.staggerDelay = 0.1,
    this.curve = Curves.easeOutCubic,
    this.slideOffset = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    final controller = _AnimationControllerProvider.of(context);
    
    if (controller == null) {
      // If no controller is provided, return child without animation
      return child;
    }

    return StaggeredListAnimation(
      controller: controller,
      index: index,
      staggerDelay: staggerDelay,
      curve: curve,
      slideOffset: slideOffset,
      child: child,
    );
  }
}
