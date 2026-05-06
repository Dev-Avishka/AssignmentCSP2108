import 'dart:async';
import 'package:flutter/material.dart';
import '../models/board.dart';
import '../logic/game_logic.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late Board board;
  bool isGameOver = false;
  String message = "Drop discs and get 4 in a row! 🔴";

  // ── Falling animation (copied from GameScreen) ────────────────────────────
  int? _droppingCol;
  int? _droppingRow;
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  double _cellSize = 48.0;
  static const double _innerPad = 12.0;
  static const double _cellMargin = 7.0;

  @override
  void initState() {
    super.initState();
    board = Board();

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

  // ── Drop logic ────────────────────────────────────────────────────────────
  Future<void> dropPiece(int col) async {
    if (isGameOver) return;

    int row = board.dropPiece(col, 1);
    if (row == -1) return;

    await _startDropAnimation(col, row);

    setState(() {});

    if (checkWin(board, 1)) {
      setState(() {
        isGameOver = true;
        message = "🎉 Excellent! You got 4 in a row!";
      });
      _showGameOverDialog(won: true);
    } else if (board.isFull()) {
      setState(() {
        isGameOver = true;
        message = "Board is full! Try again.";
      });
      _showGameOverDialog(won: false);
    }
  }

  Future<void> _startDropAnimation(int col, int row) async {
    setState(() {
      _droppingCol = col;
      _droppingRow = row;
    });
    await _dropController.forward(from: 0);
    setState(() {
      _droppingCol = null;
      _droppingRow = null;
    });
  }

  void _showGameOverDialog({required bool won}) {
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
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to menu
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              label: const Text(
                "MENU",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            Icon(
              won ? Icons.celebration : Icons.refresh,
              size: 60,
              color: won ? Colors.green[300] : Colors.orange[300],
            ),
            const SizedBox(height: 12),
            Text(
              won ? "🎉 YOU GOT IT!" : "😅 BOARD FULL!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          won
              ? "Great job! You lined up 4 in a row."
              : "No more room! Give it another shot.",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  resetTutorial();
                },
                icon: const Icon(Icons.replay, color: Colors.white, size: 28),
                label: const Text(
                  "TRY AGAIN",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetTutorial() {
    setState(() {
      board = Board();
      isGameOver = false;
      message = "Drop discs and get 4 in a row! 🔴";
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // ── Identical scaling logic from GameScreen ───────────────────────────
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
        title: const Text(
          "Interactive Tutorial",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetTutorial,
            tooltip: "Reset",
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
              // ── Status bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Board (animated sandwich) ────────────────────────────
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
                          // Layer 1 – blue back panel
                          _buildBoardBack(),

                          // Layer 2 – falling disc
                          if (_droppingCol != null && _droppingRow != null)
                            Positioned(
                              left: currentX,
                              top: currentY,
                              child: Container(
                                width: _cellSize,
                                height: _cellSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red[600],
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Layer 3 – hole mask + settled pieces
                          _buildBoardFront(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // ── Column arrows ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(Board.cols, (col) {
                    return GestureDetector(
                      onTap: () => dropPiece(col),
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

  // ── Layer 1 ───────────────────────────────────────────────────────────────
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
            color: Colors.black38,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );
  }

  // ── Layer 3 ───────────────────────────────────────────────────────────────
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
                onTap: () => dropPiece(col),
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
