import 'package:flutter/material.dart';
import 'package:namaa/cores/assets.dart';
import 'package:namaa/cores/utils/app_colors.dart';
import 'package:namaa/features/chat/views/chat_screen.dart';
import 'package:namaa/features/settings/views/settings_view.dart';
import 'package:namaa/features/stats/stats_view.dart';
import 'package:namaa/features/ticker/ticker_view.dart';
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
            child: Icon(Icons.home , size: 35, color: Colors.black54,),
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
            child: Icon(Icons.stacked_bar_chart , size: 35, color: Colors.black54,),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
            child: imagesApp.isEmpty ? SizedBox(): Image.asset(imagesApp[1] , height: 100,),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(),
                ),
              );
            },
            child: Icon(Icons.question_answer_outlined , size: 35, color: Colors.black54,),
          ),
          GestureDetector(
            onTap: () {
              if (pageName != "settings") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsView()),
                );
              }
            },
            child: Icon(Icons.settings , size: 35, color: Colors.black54,),
          ),
        ],
      ),
    );
  }
}
