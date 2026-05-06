import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  group('dropPiece & isColumnFull Tests', () {
    test('1. Pieces stack correctly — each drop lands one row above the last', () {
      int r1 = board.dropPiece(2, 1); // row 5
      int r2 = board.dropPiece(2, 2); // row 4
      int r3 = board.dropPiece(2, 1); // row 3

      expect(r1, 5);
      expect(r2, 4);
      expect(r3, 3);
      expect(board.grid[5][2], 1);
      expect(board.grid[4][2], 2);
      expect(board.grid[3][2], 1);
    });

    test('2. isColumnFull() is false on a fresh column', () {
      for (int c = 0; c < Board.cols; c++) {
        expect(board.isColumnFull(c), false);
      }
    });

    test('3. isColumnFull() becomes true after 6 drops in the same column', () {
      for (int i = 0; i < Board.rows; i++) {
        expect(board.isColumnFull(1), false);
        board.dropPiece(1, 1);
      }
      expect(board.isColumnFull(1), true);
    });

    test('4. dropPiece returns -1 for an out-of-range column index', () {
      expect(board.dropPiece(-1, 1), -1);
      expect(board.dropPiece(7, 1), -1);
      expect(board.dropPiece(100, 2), -1);
    });

    test('5. Player 2 pieces are stored correctly alongside player 1 pieces', () {
      board.dropPiece(5, 1);
      board.dropPiece(5, 2);
      board.dropPiece(5, 1);

      expect(board.grid[5][5], 1);
      expect(board.grid[4][5], 2);
      expect(board.grid[3][5], 1);
    });
  });
}
