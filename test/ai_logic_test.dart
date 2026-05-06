import 'package:flutter_test/flutter_test.dart';
import '../lib/models/board.dart';
import '../lib/logic/ai.dart';
import '../lib/logic/game_logic.dart';

void main() {
  late Board board;

  setUp(() {
    board = Board();
  });

  group('AI Logic Tests', () {
    test('1. Hard AI takes an immediate winning move (horizontal)', () {
      final ai = AI('Hard');

      // AI (player 2) has 3 in a row — column 3 completes it
      board.dropPiece(0, 2);
      board.dropPiece(1, 2);
      board.dropPiece(2, 2);
      // Column 3 is the win

      int move = ai.getBestMove(board);
      expect(move, 3, reason: 'Hard AI must complete 4-in-a-row horizontally');
    });

    test('2. Hard AI blocks player 1 from winning', () {
      final ai = AI('Hard');

      // Player 1 has 3 in a row at cols 0,1,2 — AI must block col 3
      board.dropPiece(0, 1);
      board.dropPiece(1, 1);
      board.dropPiece(2, 1);

      int move = ai.getBestMove(board);
      expect(move, 3, reason: 'Hard AI must block player 1 at column 3');
    });

    test('3. Medium AI takes an immediate winning move', () {
      final ai = AI('Medium');

      board.dropPiece(0, 2);
      board.dropPiece(1, 2);
      board.dropPiece(2, 2);

      int move = ai.getBestMove(board);
      expect(move, 3, reason: 'Medium AI must take the winning move');
    });

    test('4. Medium AI blocks player 1 from winning', () {
      final ai = AI('Medium');

      board.dropPiece(0, 1);
      board.dropPiece(1, 1);
      board.dropPiece(2, 1);

      int move = ai.getBestMove(board);
      expect(move, 3, reason: 'Medium AI must block player 1 at column 3');
    });

    test(
        '5. Any difficulty AI returns a valid (non-full) column on an empty board',
        () {
      for (final difficulty in ['Easy', 'Medium', 'Hard']) {
        final ai = AI(difficulty);
        int move = ai.getBestMove(board);

        expect(move >= 0 && move < Board.cols, true,
            reason: '$difficulty AI returned out-of-range column $move');
        expect(board.isColumnFull(move), false,
            reason: '$difficulty AI chose a full column on an empty board');
      }
    });
  });
}
