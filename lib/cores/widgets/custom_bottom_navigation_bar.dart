import 'package:flutter/material.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/chat/views/chat_screen.dart';
import 'package:namaa/features/settings/views/settings_view.dart';
import 'package:namaa/features/stats/stats_view.dart';
import 'package:namaa/main.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String? pageName;
  const CustomBottomNavigationBar({super.key, this.pageName});

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
               if (pageName == 'settings') {
                Navigator.pop(context);
              }
            },
            child: Image.asset(Assets.imagesHome),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsScreen(userIdOfApp: userIdOfApp!),
                ),
              );
            },
            child: Image.asset(Assets.imagesStatistic),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
            child: Image.asset(Assets.imagesSleverSmallCharacter),
          ),
          Image.asset(Assets.imagesReceipt),
          GestureDetector(
            onTap: () {
              if (pageName != "settings") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsView()),
                );
              }
            },
            child: Image.asset(Assets.imagesSettings),
          ),
        ],
      ),
    );
  }
}
