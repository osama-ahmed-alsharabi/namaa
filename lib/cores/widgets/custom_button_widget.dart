
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  const CustomButtonWidget({
    super.key, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
