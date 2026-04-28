import 'score_storage.dart';

class ScoreManager {
  static int wins = 0;
  static int losses = 0;
  static int draws = 0;

  // Load scores from storage when app starts
  static Future<void> init() async {
    final data = await ScoreStorage.loadScores();
    wins = data['wins']!;
    losses = data['losses']!;
    draws = data['draws']!;
  }

  // Update score after a game ends
  static Future<void> updateScore(String result) async {
    switch (result.toLowerCase()) {
      case "win":
        wins++;
        break;
      case "loss":
        losses++;
        break;
      case "draw":
        draws++;
        break;
    }
    await ScoreStorage.saveScores(wins: wins, losses: losses, draws: draws);
  }

  // Reset all scores (optional)
  static Future<void> resetAll() async {
    wins = 0;
    losses = 0;
    draws = 0;
    await ScoreStorage.clearScores();
  }

  // For displaying
  static String getStats() {
    return "Wins: $wins   |   Losses: $losses   |   Draws: $draws";
  }
}
