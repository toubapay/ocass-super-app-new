import 'package:flutter/material.dart';

class CustomWalletIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CustomWalletIcon({
    super.key,
    this.size = 20,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/image/walleticon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}