import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color qrColor;

  const AppIconWidget({
    super.key,
    this.size = 100,
    this.backgroundColor = Colors.white,
    this.qrColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.qr_code,
          size: size * 0.6,
          color: qrColor,
        ),
      ),
    );
  }
} 