import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../widgets/banner.dart';
import '../../widgets/quick_access.dart';
import '../../widgets/todays_quiz.dart';
import '../../widgets/study_materials.dart';
import '../../widgets/quick_links.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_background.dart';
import '../../widgets/secure_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecureWidget(
      child: Scaffold(
        body: SafeArea(
          child: AppBackground(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeBanner(),
                          SizedBox(height: 24),
                          QuickAccess(),
                          SizedBox(height: 24),
                          TodaysQuiz(),
                          SizedBox(height: 24),
                          StudyMaterials(),
                          SizedBox(height: 24),
                          QuickLinks(),
                        ],
                      ),
                    ),
                  ),
                ),
                BottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
