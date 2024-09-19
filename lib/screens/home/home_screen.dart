import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import '../../widgets/banner.dart';
import '../../widgets/quick_access.dart';
import '../../widgets/todays_quiz.dart';
import '../../widgets/quick_links.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_background.dart';
import '../../widgets/secure_widget.dart';
import '../../services/supabase_service.dart';
import '../study_material/study_material_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleQuickAccessTap(BuildContext context, String itemName) {
    switch (itemName) {
      case 'Notes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudyMaterialScreen()),
        );
        break;
      case 'Daily Quiz':
        // TODO: Implement navigation to Quiz screen
        break;
      case 'Syllabus':
        // TODO: Implement navigation to Syllabus screen
        break;
      case 'Strategy':
        // TODO: Implement navigation to Strategy screen
        break;
      default:
        print('Unhandled quick access item: $itemName');
    }
  }

  Future<void> _updateSessionCustomClaim(BuildContext context) async {
    try {
      await supabaseService.updateSessionCustomClaim('ssc_');
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeBanner(),
                          const SizedBox(height: 24),
                          QuickAccess(
                            onItemTap: (itemName) =>
                                _handleQuickAccessTap(context, itemName),
                          ),
                          const SizedBox(height: 24),
                          const TodaysQuiz(),
                          const SizedBox(height: 24),
                          const QuickLinks(),
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
