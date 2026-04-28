class Board {
  static const int rows = 6;
  static const int cols = 7;

  List<List<int>> grid; // 6 rows, 7 columns

  Board() : grid = List.generate(rows, (_) => List.filled(cols, 0));

  // Copy constructor (useful for undo)
  Board.copy(Board other)
    : grid = List.generate(rows, (r) => List.from(other.grid[r]));

  int dropPiece(int col, int player) {
    if (col < 0 || col >= cols) return -1;

    for (int row = rows - 1; row >= 0; row--) {
      if (grid[row][col] == 0) {
        grid[row][col] = player;
        return row; // landed row
      }
    }
    return -1; // column full
  }

  // Check if column is full
  bool isColumnFull(int col) {
    return grid[0][col] != 0;
  }

  // Check if board is completely full
  bool isFull() {
    for (int col = 0; col < cols; col++) {
      if (!isColumnFull(col)) return false;
    }
    return true;
  }

  void clear() {
    grid = List.generate(rows, (_) => List.filled(cols, 0));
  }
}
