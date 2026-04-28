import 'package:shared_preferences/shared_preferences.dart';

class ScoreStorage {
  static const String _winsKey = 'connect4_wins';
  static const String _lossesKey = 'connect4_losses';
  static const String _drawsKey = 'connect4_draws';

  // Save all scores
  static Future<void> saveScores({
    required int wins,
    required int losses,
    required int draws,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winsKey, wins);
    await prefs.setInt(_lossesKey, losses);
    await prefs.setInt(_drawsKey, draws);
  }

  // Load all scores
  static Future<Map<String, int>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'wins': prefs.getInt(_winsKey) ?? 0,
      'losses': prefs.getInt(_lossesKey) ?? 0,
      'draws': prefs.getInt(_drawsKey) ?? 0,
    };
  }

  // Clear all data (useful for testing)
  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_winsKey);
    await prefs.remove(_lossesKey);
    await prefs.remove(_drawsKey);
  }
}
