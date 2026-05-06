import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';
import '../lib/logic/game_logic.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  group('Connect 4 Game Logic Tests', () {
    test('1. Drop piece in empty column - should land at bottom (row 5)', () {
      int row = board.dropPiece(3, 1);
      expect(row, 5);
      expect(board.grid[5][3], 1);
    });

    test('2. Drop piece in full column should return -1', () {
      // Fill column 0
      for (int i = 0; i < 6; i++) {
        board.dropPiece(0, 1);
      }
      int result = board.dropPiece(0, 2);
      expect(result, -1);
    });

    test('3. Horizontal Win Detection', () {
      board.dropPiece(0, 1);
      board.dropPiece(1, 1);
      board.dropPiece(2, 1);
      board.dropPiece(3, 1);

      expect(checkWin(board, 1), true);
    });

    test('4. Vertical Win Detection', () {
      board.dropPiece(4, 2);
      board.dropPiece(4, 2);
      board.dropPiece(4, 2);
      board.dropPiece(4, 2);

      expect(checkWin(board, 2), true);
    });

    test('5. Diagonal Win Detection (Bottom-left → Top-right)', () {
      board.grid[5][0] = 1;
      board.grid[4][1] = 1;
      board.grid[3][2] = 1;
      board.grid[2][3] = 1;

      expect(checkWin(board, 1), true);
    });
  });
}
