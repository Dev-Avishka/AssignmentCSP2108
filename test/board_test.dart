import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  group('Board Model Tests', () {
    test('1. New board is fully empty (all zeros)', () {
      for (int r = 0; r < Board.rows; r++) {
        for (int c = 0; c < Board.cols; c++) {
          expect(board.grid[r][c], 0,
              reason: 'Cell [$r][$c] should be 0 on a new board');
        }
      }
    });

    test('2. Board dimensions are 6 rows x 7 columns', () {
      expect(Board.rows, 6);
      expect(Board.cols, 7);
      expect(board.grid.length, 6);
      expect(board.grid[0].length, 7);
    });

    test('3. Board.copy() produces independent deep copy', () {
      board.dropPiece(0, 1);
      board.dropPiece(3, 2);

      Board copy = Board.copy(board);

      // Verify values match
      expect(copy.grid[5][0], 1);
      expect(copy.grid[5][3], 2);

      // Mutate copy — original must NOT change
      copy.dropPiece(0, 2);
      expect(board.grid[4][0], 0,
          reason: 'Original board should not be affected by copy mutation');
    });

    test('4. clear() resets the entire board to zeros', () {
      for (int c = 0; c < Board.cols; c++) {
        board.dropPiece(c, 1);
        board.dropPiece(c, 2);
      }

      board.clear();

      for (int r = 0; r < Board.rows; r++) {
        for (int c = 0; c < Board.cols; c++) {
          expect(board.grid[r][c], 0,
              reason: 'Cell [$r][$c] should be 0 after clear()');
        }
      }
    });

    test('5. isFull() returns true only when every column is filled', () {
      expect(board.isFull(), false);

      // Fill every cell
      for (int c = 0; c < Board.cols; c++) {
        for (int r = 0; r < Board.rows; r++) {
          board.dropPiece(c, 1);
        }
      }

      expect(board.isFull(), true);
    });
  });
}
