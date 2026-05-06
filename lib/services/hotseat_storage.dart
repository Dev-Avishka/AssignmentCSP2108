import 'package:shared_preferences/shared_preferences.dart';

class HotSeatStorage {
  static const String _p1WinsKey = 'hotseat_p1_wins';
  static const String _p2WinsKey = 'hotseat_p2_wins';
  static const String _drawsKey = 'hotseat_draws';
  static Future<void> saveScores({
    required int p1Wins,
    required int p2Wins,
    required int draws,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_p1WinsKey, p1Wins);
    await prefs.setInt(_p2WinsKey, p2Wins);
    await prefs.setInt(_drawsKey, draws);
  }

  static Future<Map<String, int>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'p1Wins': prefs.getInt(_p1WinsKey) ?? 0,
      'p2Wins': prefs.getInt(_p2WinsKey) ?? 0,
      'draws': prefs.getInt(_drawsKey) ?? 0,
    };
  }

  static Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_p1WinsKey);
    await prefs.remove(_p2WinsKey);
    await prefs.remove(_drawsKey);
  }
}
