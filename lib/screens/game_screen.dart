import 'dart:async';
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../logic/game_logic.dart';
import '../logic/ai.dart';
import '../services/score_manager.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Board board;
  late AI ai;

  int currentPlayer = 1;
  String status = "Your Turn";
  bool isGameOver = false;
  String winner = "";

  List<Map<String, int>> moveHistory = [];

  // Falling Animation
  int? _droppingCol;
  int? _droppingRow;
  int? _droppingPlayer;
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  double _cellSize = 48.0;
  static const double _innerPad = 12.0;
  static const double _cellMargin = 7.0;

  @override
  void initState() {
    super.initState();
    board = Board();
    ai = AI(widget.difficulty);
    ScoreManager.init();

    _dropController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    _dropAnimation = CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  void makeMove(int col) async {
    if (isGameOver || currentPlayer != 1) return;

    int row = board.dropPiece(col, 1);
    if (row == -1) return;

    await _startDropAnimation(col, row, 1);

    moveHistory.add({"player": 1, "col": col, "row": row});
    setState(() {});

    if (_checkGameOver(1)) return;

    setState(() {
      currentPlayer = 2;
      status = "AI Thinking...";
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _makeAIMove();
  }

  Future<void> _makeAIMove() async {
    int col = ai.getBestMove(board);
    int row = board.dropPiece(col, 2);

    if (row != -1) {
      await _startDropAnimation(col, row, 2);
      moveHistory.add({"player": 2, "col": col, "row": row});
    }

    setState(() {});

    if (_checkGameOver(2)) return;

    setState(() {
      currentPlayer = 1;
      status = "Your Turn";
    });
  }

  Future<void> _startDropAnimation(int col, int row, int player) async {
    setState(() {
      _droppingCol = col;
      _droppingRow = row;
      _droppingPlayer = player;
    });

    await _dropController.forward(from: 0);

    setState(() {
      _droppingCol = null;
      _droppingRow = null;
      _droppingPlayer = null;
    });
  }

  bool _checkGameOver(int player) {
    if (checkWin(board, player)) {
      String result = player == 1 ? "win" : "loss";
      ScoreManager.updateScore(result);
      setState(() {
        isGameOver = true;
        winner = player == 1 ? "You Win! 🎉" : "AI Wins 😔";
        status = winner;
      });
      _showGameOverDialog(result);
      return true;
    }
    if (isDraw(board)) {
      ScoreManager.updateScore("draw");
      setState(() {
        isGameOver = true;
        winner = "It's a Draw!";
        status = winner;
      });
      _showGameOverDialog("draw");
      return true;
    }
    return false;
  }

  void _showGameOverDialog(String result) {
    String title = result == "win"
        ? "🎉 YOU WIN!"
        : result == "loss"
            ? "😔 AI WINS"
            : "🤝 IT'S A DRAW";

    Color titleColor = result == "win" ? Colors.green[300]! : Colors.red[300]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
        title: Column(
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              label: const Text("MENU",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            Icon(
              result == "win" ? Icons.celebration : Icons.emoji_events,
              size: 60,
              color: titleColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ScoreManager.getStats(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Total Games: ${ScoreManager.wins + ScoreManager.losses + ScoreManager.draws}",
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                icon: const Icon(Icons.replay, color: Colors.white, size: 28),
                label: const Text("PLAY AGAIN",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
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

    final double usableW = screenWidth * 0.92 - boardPad;
    final double usableH = screenHeight -
        appBarH -
        statusH -
        arrowH -
        boardPad -
        MediaQuery.of(context).padding.top;

    final double cellW = (usableW - _cellMargin * Board.cols) / Board.cols;
    final double cellH = (usableH - _cellMargin * Board.rows) / Board.rows;
    _cellSize = cellW.clamp(0.0, cellH).clamp(36.0, 64.0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Connect 4 - ${widget.difficulty}",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Smart Undo Button
          IconButton(
            icon: const Icon(Icons.undo),
            color: (moveHistory.length >= 2 && !isGameOver)
                ? Colors.white
                : Colors.grey[600],
            onPressed:
                (moveHistory.length >= 2 && !isGameOver) ? undoMove : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ScoreManager.getStats(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Board with Animation
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _dropAnimation,
                    builder: (context, _) {
                      final double cellStep = _cellSize + _cellMargin;
                      final double targetY = _innerPad +
                          (_droppingRow ?? 0) * cellStep +
                          (cellStep - _cellSize) / 2;
                      final double startY = -(_cellSize + 8);
                      final double currentY =
                          startY + (targetY - startY) * _dropAnimation.value;
                      final double currentX = _innerPad +
                          (_droppingCol ?? 0) * cellStep +
                          (cellStep - _cellSize) / 2;

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _buildBoardBack(),
                          if (_droppingCol != null && _droppingRow != null)
                            Positioned(
                              left: currentX,
                              top: currentY,
                              child: Container(
                                width: _cellSize,
                                height: _cellSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getPieceColor(_droppingPlayer!),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          _buildBoardFront(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Column Arrows
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (col) {
                    return GestureDetector(
                      onTap: () => makeMove(col),
                      child: SizedBox(
                        width: _cellSize + _cellMargin,
                        height: 40,
                        child: const Icon(
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

  Widget _buildBoardBack() {
    final double cellStep = _cellSize + _cellMargin;
    final double boardW = _innerPad * 2 + Board.cols * cellStep;
    final double boardH = _innerPad * 2 + Board.rows * cellStep;

    return Container(
      width: boardW,
      height: boardH,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, blurRadius: 15, offset: Offset(0, 10))
        ],
      ),
    );
  }

  Widget _buildBoardFront() {
    return Container(
      padding: const EdgeInsets.all(_innerPad),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(Board.rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(Board.cols, (col) {
              final bool isTarget = _droppingCol == col && _droppingRow == row;
              final int cellValue = board.grid[row][col];

              final Color fillColor = isTarget
                  ? Colors.transparent
                  : cellValue != 0
                      ? _getPieceColor(cellValue)
                      : Colors.white;

              return GestureDetector(
                onTap: () => makeMove(col),
                child: Container(
                  width: _cellSize,
                  height: _cellSize,
                  margin: const EdgeInsets.all(_cellMargin / 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue[700]!, width: 4),
                    color: fillColor,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Color _getPieceColor(int value) {
    if (value == 1) return Colors.red[600]!;
    if (value == 2) return Colors.yellow[600]!;
    return Colors.transparent;
  }
}
