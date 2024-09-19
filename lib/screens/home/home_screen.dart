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
import '../../services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _updateSessionCustomClaim(BuildContext context) async {
    try {
      await supabaseService.updateSessionCustomClaim('ssc_gd');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Session custom claim updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating session custom claim: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      child: Scaffold(
        body: SafeArea(
          child: AppBackground(
            child: Column(
              children: [
                const Header(),
                const Expanded(
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
                ElevatedButton(
                  onPressed: () => _updateSessionCustomClaim(context),
                  child: const Text('Update Session Custom Claim'),
                ),
                const BottomNavigation(currentRoute: '/home'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
