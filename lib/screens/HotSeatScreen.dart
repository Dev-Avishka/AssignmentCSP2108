import 'package:flutter/material.dart';
import '../models/board.dart';
import '../logic/game_logic.dart';

class HotSeatScreen extends StatefulWidget {
  const HotSeatScreen({super.key});

  @override
  State<HotSeatScreen> createState() => _HotSeatScreenState();
}

class _HotSeatScreenState extends State<HotSeatScreen>
    with TickerProviderStateMixin {
  late Board board;
  int currentPlayer = 1; // 1 = Red (Player 1), 2 = Yellow (Player 2)
  String status = "Player 1 (Red) Turn";
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
    if (isGameOver) return;
    // Block input during animation
    if (_droppingCol != null) return;

    int row = board.dropPiece(col, currentPlayer);
    if (row == -1) return; // Column full

    int movingPlayer = currentPlayer;

    await _startDropAnimation(col, row, movingPlayer);

    moveHistory.add({"player": movingPlayer, "col": col, "row": row});
    setState(() {});

    if (_checkGameOver(movingPlayer)) return;

    // Switch player
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    setState(() {
      status =
          currentPlayer == 1 ? "Player 1 (Red) Turn" : "Player 2 (Yellow) Turn";
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
      setState(() {
        isGameOver = true;
        winner = player == 1
            ? "Player 1 (Red) Wins! 🎉"
            : "Player 2 (Yellow) Wins! 🎉";
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

  void resetGame() {
    setState(() {
      board = Board();
      currentPlayer = 1;
      status = "Player 1 (Red) Turn";
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
        title: const Text(
          "Hotseat - 2 Players",
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
            color: const Color(0xFFFFFFFF), // Direct color property
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
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                                    ),
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
                  children: List.generate(Board.cols, (col) {
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
            color: Colors.black38,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
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
