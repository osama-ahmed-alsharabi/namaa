
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const CustomButtonWidget({
    super.key, required this.text, this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Color.fromARGB( 200,130, 118 ,49),
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
