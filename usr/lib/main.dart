import 'package:flutter/material.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ChessScreen(),
      },
    );
  }
}

enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

class ChessPiece {
  PieceType type;
  PieceColor color;

  ChessPiece(this.type, this.color);

  String get symbol {
    switch (type) {
      case PieceType.king:
        return color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:
        return color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:
        return color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop:
        return color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight:
        return color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:
        return color == PieceColor.white ? '♙' : '♟';
    }
  }
}

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late List<List<ChessPiece?>> board;
  PieceColor currentTurn = PieceColor.white;
  ChessPiece? selectedPiece;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board = List.generate(8, (row) => List.generate(8, (col) {
      if (row == 0) {
        switch (col) {
          case 0:
          case 7:
            return ChessPiece(PieceType.rook, PieceColor.black);
          case 1:
          case 6:
            return ChessPiece(PieceType.knight, PieceColor.black);
          case 2:
          case 5:
            return ChessPiece(PieceType.bishop, PieceColor.black);
          case 3:
            return ChessPiece(PieceType.queen, PieceColor.black);
          case 4:
            return ChessPiece(PieceType.king, PieceColor.black);
        }
      } else if (row == 1) {
        return ChessPiece(PieceType.pawn, PieceColor.black);
      } else if (row == 6) {
        return ChessPiece(PieceType.pawn, PieceColor.white);
      } else if (row == 7) {
        switch (col) {
          case 0:
          case 7:
            return ChessPiece(PieceType.rook, PieceColor.white);
          case 1:
          case 6:
            return ChessPiece(PieceType.knight, PieceColor.white);
          case 2:
          case 5:
            return ChessPiece(PieceType.bishop, PieceColor.white);
          case 3:
            return ChessPiece(PieceType.queen, PieceColor.white);
          case 4:
            return ChessPiece(PieceType.king, PieceColor.white);
        }
      }
      return null;
    }));
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    var piece = board[fromRow][fromCol];
    if (piece == null) return false;

    int rowDiff = (toRow - fromRow).abs();
    int colDiff = (toCol - fromCol).abs();

    switch (piece.type) {
      case PieceType.pawn:
        int direction = piece.color == PieceColor.white ? -1 : 1;
        if (fromCol == toCol && board[toRow][toCol] == null) {
          if (rowDiff == 1 && toRow == fromRow + direction) return true;
          if (rowDiff == 2 &&
              ((piece.color == PieceColor.white && fromRow == 6) ||
               (piece.color == PieceColor.black && fromRow == 1)) &&
              board[fromRow + direction][fromCol] == null) return true;
        } else if (colDiff == 1 && rowDiff == 1 && toRow == fromRow + direction) {
          return board[toRow][toCol] != null && board[toRow][toCol]!.color != piece.color;
        }
        break;
      case PieceType.rook:
        if ((rowDiff == 0 || colDiff == 0) && isPathClear(fromRow, fromCol, toRow, toCol)) return true;
        break;
      case PieceType.bishop:
        if (rowDiff == colDiff && isPathClear(fromRow, fromCol, toRow, toCol)) return true;
        break;
      case PieceType.queen:
        if ((rowDiff == colDiff || rowDiff == 0 || colDiff == 0) && isPathClear(fromRow, fromCol, toRow, toCol)) return true;
        break;
      case PieceType.knight:
        if ((rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)) return true;
        break;
      case PieceType.king:
        if (rowDiff <= 1 && colDiff <= 1) return true;
        break;
    }
    return false;
  }

  bool isPathClear(int fromRow, int fromCol, int toRow, int toCol) {
    int rowStep = toRow > fromRow ? 1 : toRow < fromRow ? -1 : 0;
    int colStep = toCol > fromCol ? 1 : toCol < fromCol ? -1 : 0;
    int row = fromRow + rowStep;
    int col = fromCol + colStep;
    while (row != toRow || col != toCol) {
      if (board[row][col] != null) return false;
      row += rowStep;
      col += colStep;
    }
    return true;
  }

  void onSquareTap(int row, int col) {
    setState(() {
      if (selectedPiece == null) {
        if (board[row][col] != null && board[row][col]!.color == currentTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else {
        if (isValidMove(selectedRow!, selectedCol!, row, col)) {
          board[row][col] = selectedPiece;
          board[selectedRow!][selectedCol!] = null;
          currentTurn = currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
        }
        selectedPiece = null;
        selectedRow = null;
        selectedCol = null;
      }
    });
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      currentTurn = PieceColor.white;
      selectedPiece = null;
      selectedRow = null;
      selectedCol = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${currentTurn == PieceColor.white ? 'White' : 'Black'}'s turn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isLight = (row + col) % 2 == 0;
                bool isSelected = selectedRow == row && selectedCol == col;
                return GestureDetector(
                  onTap: () => onSquareTap(row, col),
                  child: Container(
                    color: isSelected
                        ? Colors.yellow
                        : isLight
                            ? Colors.white
                            : Colors.brown,
                    child: Center(
                      child: Text(
                        board[row][col]?.symbol ?? '',
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: resetGame,
        tooltip: 'Reset Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}