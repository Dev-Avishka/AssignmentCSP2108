import 'package:flutter/material.dart';
import 'tutorial_screen.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("How to Play Connect 4",
              style: TextStyle(color: Color(0xFFFFFFFF))),
          backgroundColor: const Color(0xFF1E3A8A),
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Objective",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const Text(
              "Be the first to connect four of your discs in a row — horizontally, vertically, or diagonally.",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),

            const SizedBox(height: 30),

            const Text("How to Play",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 15),
            _buildRuleItem("1. Tap any column to drop your Red disc."),
            _buildRuleItem("2. Discs fall to the lowest available spot."),
            _buildRuleItem("3. Yellow is the AI opponent."),
            _buildRuleItem("4. First to get 4 in a row wins!"),

            const SizedBox(height: 30),

            const Text("Winning Ways",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 15),
            _buildWinType("Horizontal", "Four discs side by side"),
            _buildWinType("Vertical", "Four discs in a column"),
            _buildWinType("Diagonal", "Four discs diagonally"),

            const SizedBox(height: 40),

            // Demo Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TutorialScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 30),
                label: const Text("TRY INTERACTIVE DEMO",
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 18, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildWinType(String title, String desc) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(title,
            style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
