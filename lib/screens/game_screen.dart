import 'dart:async';
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../logic/game_logic.dart';
import '../logic/ai.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Board board;
  late AI ai;

  int currentPlayer = 1;
  String status = "Your Turn";
  bool isGameOver = false;
  String winner = "";
  List<Map<String, int>> moveHistory = [];

  @override
  void initState() {
    super.initState();
    board = Board();
    ai = AI(widget.difficulty);
  }

  void makeMove(int col) async {
    if (isGameOver || currentPlayer != 1) return;

    int row = board.dropPiece(col, 1);
    if (row == -1) return;

    moveHistory.add({"player": 1, "col": col, "row": row});
    setState(() {});

    if (_checkGameOver(1)) return;

    setState(() {
      currentPlayer = 2;
      status = "AI Thinking...";
    });

    await Future.delayed(const Duration(milliseconds: 700));
    await _makeAIMove();
  }

  Future<void> _makeAIMove() async {
    int col = ai.getBestMove(board);

    int row = board.dropPiece(col, 2);
    if (row != -1) {
      moveHistory.add({"player": 2, "col": col, "row": row});
    }

    setState(() {});

    if (_checkGameOver(2)) return;

    setState(() {
      currentPlayer = 1;
      status = "Your Turn";
    });
  }

  bool _checkGameOver(int player) {
    if (checkWin(board, player)) {
      setState(() {
        isGameOver = true;
        winner = player == 1 ? "You Win! 🎉" : "AI Wins 😔";
        status = winner;
      });
      return true;
    }
    if (isDraw(board)) {
      setState(() {
        isGameOver = true;
        winner = "It's a Draw!";
        status = winner;
      });
      return true;
    }
    return false;
  }

  void undoMove() {
    if (moveHistory.length < 2 || isGameOver) return;
    var lastAIMove = moveHistory.removeLast();
    board.grid[lastAIMove["row"]!][lastAIMove["col"]!] = 0;

    var lastPlayerMove = moveHistory.removeLast();
    board.grid[lastPlayerMove["row"]!][lastPlayerMove["col"]!] = 0;

    setState(() {
      currentPlayer = 1;
      status = "Your Turn";
    });
  }

  void resetGame() {
    setState(() {
      board = Board();
      currentPlayer = 1;
      status = "Your Turn";
      isGameOver = false;
      winner = "";
      moveHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const double appBarH = kToolbarHeight;
    const double statusH = 70;
    const double arrowH = 65;
    const double boardPad = 24;
    const double cellMargin = 7;

    final double usableW = screenWidth * 0.92 - boardPad;
    final double usableH = screenHeight -
        appBarH -
        statusH -
        arrowH -
        boardPad -
        MediaQuery.of(context).padding.top;

    final double cellW = (usableW - cellMargin * Board.cols) / Board.cols;
    final double cellH = (usableH - cellMargin * Board.rows) / Board.rows;
    final double cellSize = cellW.clamp(0.0, cellH).clamp(36.0, 64.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Connect 4 - ${widget.difficulty}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: undoMove),
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetGame),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
          ),
        ),
        child: SizedBox(
          height: screenHeight - MediaQuery.of(context).padding.top,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // spreads content evenly
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 15,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(Board.rows, (row) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(Board.cols, (col) {
                          return GestureDetector(
                            onTap: () => makeMove(col),
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              margin: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.blue[700]!, width: 4),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getPieceColor(board.grid[row][col]),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),

              // Arrow row — bigger and more visible
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (col) {
                    return GestureDetector(
                      onTap: () => makeMove(col),
                      child: SizedBox(
                        width: cellSize + 7,
                        height: 40,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPieceColor(int value) {
    if (value == 1) return Colors.red[600]!;
    if (value == 2) return Colors.yellow[600]!;
    return Colors.transparent;
  }
}
