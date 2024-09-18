import 'package:flutter/material.dart';

class TodaysQuiz extends StatelessWidget {
  const TodaysQuiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Quiz",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.access_time, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Time: 15 minutes',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Questions: 20',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue[500],
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }
}
