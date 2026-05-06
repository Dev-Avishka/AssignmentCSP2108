import 'hotseat_storage.dart';

class HotSeatManager {
  static int p1Wins = 0;
  static int p2Wins = 0;
  static int draws = 0;

  static Future<void> init() async {
    final data = await HotSeatStorage.loadScores();
    p1Wins = data['p1Wins']!;
    p2Wins = data['p2Wins']!;
    draws = data['draws']!;
  }

  static Future<void> updateScore(String result) async {
    switch (result.toLowerCase()) {
      case "p1":
        p1Wins++;
        break;
      case "p2":
        p2Wins++;
        break;
      case "draw":
        draws++;
        break;
    }
    await HotSeatStorage.saveScores(
        p1Wins: p1Wins, p2Wins: p2Wins, draws: draws);
  }

  static Future<void> resetAll() async {
    p1Wins = 0;
    p2Wins = 0;
    draws = 0;
    await HotSeatStorage.clearScores();
  }

  static String getStats() {
    return "P1: $p1Wins   |   P2: $p2Wins   |   Draws: $draws ";
  }

  static int get totalGames => p1Wins + p2Wins + draws;
}
