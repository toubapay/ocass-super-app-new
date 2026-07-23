import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final VoidCallback onTap;
  final double size;
  final bool? fromAirTime;

  const ActionIcon(
      {super.key,
      this.icon,
      this.imagePath,
      required this.title,
      required this.onTap,
      this.size = 16,
      this.fromAirTime})
      : assert(
          icon != null || imagePath != null,
          'Either icon or imagePath must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                color:
                    fromAirTime == true ? Colors.white : primaryColor, // ✅ FIX
                borderRadius: BorderRadius.circular(10) // ✅ CLEAN LOOK
                ),
            alignment: Alignment.center,
            child: imagePath != null
                ? Image.asset(
                    imagePath!,
                    width: size,
                    height: size,
                    color: fromAirTime == true ? Colors.green : Colors.white,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: size,
                  ),
          ),
          const SizedBox(height: 0),
          Text(
            title,
            style: TextStyle(
                fontSize: fromAirTime == true ? 15 : 12,
                color: fromAirTime == true ? Colors.white : null),
          ),
        ],
      ),
    );
  }
}
