import 'package:flutter/material.dart';
import 'package:namaa/cores/utils/app_colors.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final double? height;
  final Color? color;
  const CustomButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.height, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 90,
        decoration: BoxDecoration(
          color: color ?? AppColors.brownColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
