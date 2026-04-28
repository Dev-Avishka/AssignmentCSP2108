import 'dart:math';
import '../models/board.dart';
import 'game_logic.dart';

class AI {
  final String difficulty;

  AI(this.difficulty);

  // Main entry point
  int getBestMove(Board board) {
    switch (difficulty) {
      case "Easy":
        return _getEasyMove(board);
      case "Medium":
        return _getMediumMove(board);
      case "Hard":
      default:
        return _getHardMove(board);
    }
  }

 
  int _getEasyMove(Board board) {
    final random = Random();

  
    int move = _findWinningMove(board, 2); 
    if (move != -1) return move;

  
    if (random.nextDouble() > 0.25) {
      move = _findWinningMove(board, 1); 
      if (move != -1) return move;
    }

    // Occasional sabotage attempt
    if (random.nextDouble() < 0.35) {
      move = _findSabotageMove(board, 2);
      if (move != -1) return move;
    }

    // Random but prefers center
    return _getCentreWeightedRandom(board);
  }

  // ====================== MEDIUM ======================
  int _getMediumMove(Board board) {
    // 1. CONNECT
    int move = _findWinningMove(board, 2);
    if (move != -1) return move;

    // 2. BLOCK
    move = _findWinningMove(board, 1);
    if (move != -1) return move;

    // 3. SABOTAGE - Create threat
    move = _findSabotageMove(board, 2);
    if (move != -1) return move;

    // Block opponent's sabotage sometimes
    if (Random().nextDouble() > 0.4) {
      move = _findSabotageMove(board, 1);
      if (move != -1) return move;
    }

    // Center preference
    if (!board.isColumnFull(3)) return 3;
    if (!board.isColumnFull(2)) return 2;
    if (!board.isColumnFull(4)) return 4;

    return _getCentreWeightedRandom(board);
  }

  // ====================== HARD ======================
  // Strong rules-based AI following Pseudocode 1 exactly + smart extensions
  int _getHardMove(Board board) {
    // 1. CONNECT - Win immediately
    int move = _findWinningMove(board, 2);
    if (move != -1) return move;

    // 2. BLOCK - Prevent player from winning
    move = _findWinningMove(board, 1);
    if (move != -1) return move;

    // 3. SABOTAGE - Create strong threats (3 in a row with open win)
    move = _findSabotageMove(board, 2);
    if (move != -1) return move;

    // Extra Hard Mode intelligence: Block opponent's threat creation
    move = _findSabotageMove(board, 1);
    if (move != -1) return move;

    // 4. Center Column
    if (!board.isColumnFull(3)) return 3;

    // 5. Columns next to center
    if (!board.isColumnFull(2)) return 2;
    if (!board.isColumnFull(4)) return 4;

    // 6. Any good available move
    return _getCentreWeightedRandom(board);
  }

  
  
  int _findWinningMove(Board board, int player) {
    for (int col = 0; col < Board.cols; col++) {
      if (board.isColumnFull(col)) continue;

      Board temp = Board.copy(board);
      int row = temp.dropPiece(col, player);
      if (row != -1 && checkWin(temp, player)) {
        return col;
      }
    }
    return -1;
  }

  // 3. SABOTAGE - Create 3-in-a-row with a winning threat
  int _findSabotageMove(Board board, int player) {
    for (int col = 0; col < Board.cols; col++) {
      if (board.isColumnFull(col)) continue;

      Board temp = Board.copy(board);
      int row = temp.dropPiece(col, player);
      if (row == -1) continue;

      // Does this move create at least one immediate winning threat?
      if (_hasWinningThreat(temp, player)) {
        return col;
      }
    }
    return -1;
  }

  // Helper: Does the player have a winning move available right now?
  bool _hasWinningThreat(Board board, int player) {
    for (int col = 0; col < Board.cols; col++) {
      if (board.isColumnFull(col)) continue;
      Board temp = Board.copy(board);
      if (temp.dropPiece(col, player) != -1 && checkWin(temp, player)) {
        return true;
      }
    }
    return false;
  }

  // Centre-biased random (used by all difficulties)
  int _getCentreWeightedRandom(Board board) {
    final List<int> available = [];
    final weights = [1, 2, 3, 4, 3, 2, 1]; // columns 0 to 6

    for (int col = 0; col < Board.cols; col++) {
      if (!board.isColumnFull(col)) {
        for (int i = 0; i < weights[col]; i++) {
          available.add(col);
        }
      }
    }

    if (available.isEmpty) return 3;
    return available[Random().nextInt(available.length)];
  }
}
