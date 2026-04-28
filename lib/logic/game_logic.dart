import '../models/board.dart';

bool checkWin(Board board, int player) {
  final grid = board.grid;

  // Horizontal
  for (int r = 0; r < Board.rows; r++) {
    for (int c = 0; c <= Board.cols - 4; c++) {
      if (grid[r][c] == player &&
          grid[r][c + 1] == player &&
          grid[r][c + 2] == player &&
          grid[r][c + 3] == player) return true;
    }
  }

  // Vertical
  for (int c = 0; c < Board.cols; c++) {
    for (int r = 0; r <= Board.rows - 4; r++) {
      if (grid[r][c] == player &&
          grid[r + 1][c] == player &&
          grid[r + 2][c] == player &&
          grid[r + 3][c] == player) return true;
    }
  }

  // Diagonal (bottom-left to top-right)
  for (int r = 0; r <= Board.rows - 4; r++) {
    for (int c = 0; c <= Board.cols - 4; c++) {
      if (grid[r][c] == player &&
          grid[r + 1][c + 1] == player &&
          grid[r + 2][c + 2] == player &&
          grid[r + 3][c + 3] == player) return true;
    }
  }

  // Diagonal (top-left to bottom-right)
  for (int r = 0; r <= Board.rows - 4; r++) {
    for (int c = 3; c < Board.cols; c++) {
      if (grid[r][c] == player &&
          grid[r + 1][c - 1] == player &&
          grid[r + 2][c - 2] == player &&
          grid[r + 3][c - 3] == player) return true;
    }
  }

  return false;
}

bool isDraw(Board board) {
  return board.isFull() && !checkWin(board, 1) && !checkWin(board, 2);
}