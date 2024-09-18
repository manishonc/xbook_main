import 'package:flutter/material.dart';
import 'profile_model.dart';
import '../../widgets/bottom_navigation.dart';
import '../../services/supabase_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProfile = UserProfile.staticProfile();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F0FE), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(context, userProfile),
              ),
              const BottomNavigation(currentRoute: '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder for balance
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.indigo, size: 20),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildProfileCard(profile),
          const SizedBox(height: 16),
          _buildStatsGrid(profile),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 32, color: Colors.indigo),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileDetail('Target Exam:', profile.targetExam),
          _buildProfileDetail('Exam Year:', profile.examYear),
          _buildProfileDetail('Preferred Language:', profile.preferredLanguage),
          _buildProfileDetail('Optional Subject:', profile.optionalSubject),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E40AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProfile profile) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildStatCard(
            Icons.emoji_events, profile.studyStreak.toString(), 'Day Streak'),
        _buildStatCard(
            Icons.trending_up, profile.testsCompleted.toString(), 'Tests Done'),
        _buildStatCard(Icons.bookmark, profile.bookmarkedResources.toString(),
            'Bookmarks'),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.indigo),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E40AF),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionButton(context, Icons.settings, 'App Settings'),
          _buildActionButton(context, Icons.book, 'Study Resources'),
          _buildActionButton(context, Icons.calendar_today, 'Exam Calendar'),
          _buildActionButton(context, Icons.logout, 'Log Out', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label,
      {bool isLogout = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.indigo),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isLogout ? Colors.red : const Color(0xFF1E40AF),
          ),
        ),
        onTap: () async {
          if (isLogout) {
            await supabaseService.signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context)
                .pushReplacementNamed('/login'); // Adjust the route as needed
          } else {
            // TODO: Implement other action button functionality
          }
        },
      ),
    );
  }
}
