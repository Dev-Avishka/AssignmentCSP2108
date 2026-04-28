import 'package:flutter/material.dart';
import 'game_screen.dart'; // We'll create this next

class Menu2Screen extends StatelessWidget {
  const Menu2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const Spacer(),

              const Text(
                "Select Difficulty",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 60),

              // Difficulty Buttons
              _buildDifficultyButton(
                context,
                title: "Easy",
                color: Colors.green,
                onTap: () => _startGame(context, "Easy"),
              ),

              const SizedBox(height: 20),

              _buildDifficultyButton(
                context,
                title: "Medium",
                color: Colors.orange,
                onTap: () => _startGame(context, "Medium"),
              ),

              const SizedBox(height: 20),

              _buildDifficultyButton(
                context,
                title: "Hard",
                color: Colors.red,
                onTap: () => _startGame(context, "Hard"),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: difficulty),
      ),
    );
  }
}
