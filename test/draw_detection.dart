import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';
import '../lib/logic/game_logic.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  // Helper: fill the board so no 4-in-a-row exists for either player.
  // Pattern alternates players across rows to avoid any win streak.
  void fillBoardDraw() {
    // Fill using a checkerboard-style pattern, row by row from bottom
    // Row 5 (bottom): 1,2,1,2,1,2,1
    // Row 4:          2,1,2,1,2,1,2
    // Row 3:          1,2,1,2,1,2,1
    // Row 2:          2,1,2,1,2,1,2
    // Row 1:          1,2,1,2,1,2,1
    // Row 0 (top):    2,1,2,1,2,1,2
    // This produces no horizontal/vertical/diagonal 4-in-a-row.
    for (int r = Board.rows - 1; r >= 0; r--) {
      for (int c = 0; c < Board.cols; c++) {
        // Alternate based on (row + col) parity
        int player = ((r + c) % 2 == 0) ? 1 : 2;
        board.grid[r][c] = player;
      }
    }
  }

  group('Draw Detection Tests', () {
    test('1. isDraw() is false on an empty board', () {
      expect(isDraw(board), false);
    });

    test('2. isDraw() is false when board is partially filled with no win', () {
      board.dropPiece(0, 1);
      board.dropPiece(1, 2);
      expect(isDraw(board), false);
    });

    test('3. isDraw() is true when board is full and no winner', () {
      fillBoardDraw();
      expect(board.isFull(), true);
      expect(checkWin(board, 1), false);
      expect(checkWin(board, 2), false);
      expect(isDraw(board), true);
    });

    test('4. isDraw() is false when board is full but player 1 has won', () {
      fillBoardDraw();
      // Force a horizontal win for player 1 on the bottom row
      board.grid[5][0] = 1;
      board.grid[5][1] = 1;
      board.grid[5][2] = 1;
      board.grid[5][3] = 1;

      expect(board.isFull(), true);
      expect(checkWin(board, 1), true);
      expect(isDraw(board), false);
    });

    test('5. isDraw() is false when board is full but player 2 has won', () {
      fillBoardDraw();
      // Force a vertical win for player 2 on column 6
      board.grid[5][6] = 2;
      board.grid[4][6] = 2;
      board.grid[3][6] = 2;
      board.grid[2][6] = 2;

      expect(board.isFull(), true);
      expect(checkWin(board, 2), true);
      expect(isDraw(board), false);
    });
  });
}
