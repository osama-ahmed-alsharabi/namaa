import 'package:flutter/material.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/chat/views/chat_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.brownColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
            child: Image.asset(Assets.imagesHome),
          ),
          Image.asset(Assets.imagesStatistic),
          Image.asset(Assets.imagesCharacter),
          Image.asset(Assets.imagesReceipt),
          Image.asset(Assets.imagesSettings),
        ],
      ),
    );
  }
}
