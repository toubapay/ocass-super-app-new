import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnHover extends StatefulWidget {
  final Widget? child;
  final bool isItem;
  final double borderRadius;
  const OnHover({super.key, this.child, this.isItem = false, this.borderRadius = 5});

  @override
  State<OnHover> createState() => _OnHoverState();
}

class _OnHoverState extends State<OnHover> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    final hoverTransformed = Matrix4.identity()..translateByDouble(1.05, 1.03, 0, 1);
    final transform = isHovered ? hoverTransformed : Matrix4.identity();
    final shedow1 = BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        BoxShadow(
          color: Get.isDarkMode ? Colors.grey.shade500.withValues(alpha: 0.4) :  Theme.of(context).colorScheme.primary.withValues(alpha: 0.13),
          blurRadius: Get.isDarkMode ? 5 : 10,
          spreadRadius: Get.isDarkMode ? 2 : 5,
          offset: const Offset(0, 1),
        )
      ],

    );
    final shedow2 = BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0),
          blurRadius: 0,
          offset: const Offset(0, 0),
        )
      ],
    );
    return MouseRegion(
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: widget.isItem ? isHovered ? shedow1 : shedow2 : shedow2,
        transform: widget.isItem ? Matrix4.identity() : transform  ,
        child: widget.child,
      ),
    );
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }
}
