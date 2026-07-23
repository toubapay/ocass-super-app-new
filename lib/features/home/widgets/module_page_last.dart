import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  final String line1;
  final String line2;
  final String subLine;
  final Color textColor;
  final double textSize;
  final FontWeight textWeight;
  final double textSpacing;
  final Color subLineColor;
  final double subLineSize;
  final FontWeight subLineWeight;
  final double subLineSpacing;

  const HeaderWidget({
    super.key,
    this.line1 = "Senegal's last",
    this.line2 = "Minute app",
    this.subLine = "Made in Bihar- ek Bihari",
    this.textColor = Colors.grey,
    this.textSize = 50,
    this.textWeight = FontWeight.w900,
    this.textSpacing = 0,
    this.subLineColor = Colors.grey,
    this.subLineSize = 20,
    this.subLineWeight = FontWeight.w600,
    this.subLineSpacing = 8,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Big Texts ===
          Text(
            widget.line1,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
              fontFamily: 'Alan Sans',
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: widget.textSpacing),
          Text(
            widget.line2,
            style: TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
              fontFamily: 'Alan Sans',
              letterSpacing: -1,
            ),
          ),

          // === Subline with animated heart ===
          SizedBox(height: widget.subLineSpacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.subLine,
                style: TextStyle(
                  fontSize: widget.subLineSize,
                  fontWeight: widget.subLineWeight,
                  color: widget.subLineColor,
                  fontFamily: 'Alan Sans',
                ),
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: const Text('❤️', style: TextStyle(fontSize: 20)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
