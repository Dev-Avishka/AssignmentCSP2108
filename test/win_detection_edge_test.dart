import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';
import '../lib/logic/game_logic.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  group('Win Detection Edge Case Tests', () {
    test('1. No win on empty board', () {
      expect(checkWin(board, 1), false);
      expect(checkWin(board, 2), false);
    });

    test('2. Three in a row does NOT trigger a win', () {
      board.dropPiece(0, 1);
      board.dropPiece(1, 1);
      board.dropPiece(2, 1);

      expect(checkWin(board, 1), false);
    });

    test('3. Anti-diagonal win (top-left → bottom-right) is detected', () {
      // Build the staircase so pieces land at the right rows
      // Col 3: drop 1 piece (lands row 5) → player 1 at [5][3]
      board.dropPiece(3, 2); // filler — row 5
      board.dropPiece(3, 2); // filler — row 4
      board.dropPiece(3, 2); // filler — row 3
      board.dropPiece(3, 1); // row 2 — player 1

      board.dropPiece(4, 2); // filler — row 5
      board.dropPiece(4, 2); // filler — row 4
      board.dropPiece(4, 1); // row 3 — player 1

      board.dropPiece(5, 2); // filler — row 5
      board.dropPiece(5, 1); // row 4 — player 1

      board.dropPiece(6, 1); // row 5 — player 1

      // Verify positions before asserting win
      expect(board.grid[2][3], 1);
      expect(board.grid[3][4], 1);
      expect(board.grid[4][5], 1);
      expect(board.grid[5][6], 1);

      expect(checkWin(board, 1), true);
    });

    test('4. Win at the very top of a column is detected (vertical)', () {
      // Fill column 6 with 5 player-2 pieces then one player-1 piece to top it
      for (int i = 0; i < 4; i++) board.dropPiece(6, 1);

      expect(checkWin(board, 1), true);
    });

    test('5. Opponent pieces in the middle do NOT create a false win', () {
      // P1 at cols 0,1 — P2 in col 2 — P1 at cols 3,4  (broken streak)
      board.dropPiece(0, 1);
      board.dropPiece(1, 1);
      board.dropPiece(2, 2); // blocker
      board.dropPiece(3, 1);
      board.dropPiece(4, 1);

      expect(checkWin(board, 1), false);
    });
  });
}
