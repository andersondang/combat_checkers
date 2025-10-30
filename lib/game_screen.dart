import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final bool isVsComputer;
  
  const GameScreen({super.key, required this.isVsComputer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameLogic game;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    game = GameLogic(widget.isVsComputer);
  }

  void _onSquareTap(int row, int col) {
    setState(() {
      if (selectedRow == null) {
        if (game.canSelectPiece(row, col)) {
          selectedRow = row;
          selectedCol = col;
        }
      } else {
        if (selectedRow == row && selectedCol == col) {
          selectedRow = null;
          selectedCol = null;
        } else if (game.makeMove(selectedRow!, selectedCol!, row, col)) {
          selectedRow = null;
          selectedCol = null;
          if (widget.isVsComputer && game.currentPlayer == 2) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                game.makeComputerMove();
              });
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Player ${game.currentPlayer}\'s Turn'),
        backgroundColor: game.currentPlayer == 1 ? Colors.red : Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (game.winner != 0)
                Text(
                  'Player ${game.winner} Wins!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlayerStatus(1),
                    _buildPlayerStatus(2),
                  ],
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(5, 5),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                        ),
                        itemCount: 64,
                        itemBuilder: (context, index) {
                          int row = index ~/ 8;
                          int col = index % 8;
                          return _buildSquare(row, col);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    game = GameLogic(widget.isVsComputer);
                    selectedRow = null;
                    selectedCol = null;
                  });
                },
                child: const Text('New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquare(int row, int col) {
    bool isSelected = selectedRow == row && selectedCol == col;
    bool isValidMove = selectedRow != null && game.isValidMove(selectedRow!, selectedCol!, row, col);
    bool isDark = (row + col) % 2 == 1;
    
    return GestureDetector(
      onTap: () => _onSquareTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getSquareGradient(row, col, isSelected, isValidMove, isDark),
          ),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: isDark ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ] : null,
        ),
        child: _buildPiece(row, col),
      ),
    );
  }

  List<Color> _getSquareGradient(int row, int col, bool isSelected, bool isValidMove, bool isDark) {
    if (isSelected) {
      return [Colors.yellow[300]!, Colors.yellow[600]!];
    }
    if (isValidMove) {
      return [Colors.green[300]!, Colors.green[600]!];
    }
    if (isDark) {
      return [Colors.brown[600]!, Colors.brown[800]!];
    } else {
      return [Colors.brown[200]!, Colors.brown[400]!];
    }
  }

  Widget _buildPlayerStatus(int player) {
    int pieces = game.getPieceCount(player);
    bool isCurrentPlayer = game.currentPlayer == player;
    
    return Tooltip(
      message: 'Player $player has $pieces pieces remaining',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPlayer 
              ? (player == 1 ? Colors.red : Colors.blue)
              : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
          border: isCurrentPlayer 
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: player == 1 ? Colors.red : Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'P$player: $pieces',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildPiece(int row, int col) {
    int piece = game.board[row][col];
    if (piece == 0) return null;
    
    bool isKing = piece > 2;
    int player = piece > 2 ? piece - 2 : piece;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow layer for 3D effect
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, left: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          // Main piece
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  player == 1 ? Colors.red[300]! : Colors.blue[300]!,
                  player == 1 ? Colors.red[800]! : Colors.blue[800]!,
                ],
                stops: const [0.3, 1.0],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(3, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: isKing
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class GameLogic {
  List<List<int>> board = List.generate(8, (_) => List.filled(8, 0));
  int currentPlayer = 1;
  int winner = 0;
  bool isVsComputer;

  GameLogic(this.isVsComputer) {
    _initializeBoard();
  }

  void _initializeBoard() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 == 1) {
          if (row < 3) {
            board[row][col] = 2; // Player 2 pieces
          } else if (row > 4) {
            board[row][col] = 1; // Player 1 pieces
          }
        }
      }
    }
  }

  bool canSelectPiece(int row, int col) {
    int piece = board[row][col];
    return piece != 0 && (piece == currentPlayer || piece == currentPlayer + 2);
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (toRow < 0 || toRow >= 8 || toCol < 0 || toCol >= 8) return false;
    if (board[toRow][toCol] != 0) return false;

    int piece = board[fromRow][fromCol];
    bool isKing = piece > 2;
    int player = piece > 2 ? piece - 2 : piece;

    int rowDiff = toRow - fromRow;
    int colDiff = (toCol - fromCol).abs();

    if (colDiff != rowDiff.abs()) return false;

    if (!isKing) {
      if (player == 1 && rowDiff > 0) return false;
      if (player == 2 && rowDiff < 0) return false;
    }

    if (rowDiff.abs() == 1) return true;

    if (rowDiff.abs() == 2) {
      int midRow = fromRow + rowDiff ~/ 2;
      int midCol = fromCol + colDiff ~/ 2 * (toCol > fromCol ? 1 : -1);
      int midPiece = board[midRow][midCol];
      
      if (midPiece == 0) return false;
      int midPlayer = midPiece > 2 ? midPiece - 2 : midPiece;
      return midPlayer != player;
    }

    return false;
  }

  bool makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    if (!isValidMove(fromRow, fromCol, toRow, toCol)) return false;

    int piece = board[fromRow][fromCol];
    board[fromRow][fromCol] = 0;
    board[toRow][toCol] = piece;

    if ((toRow - fromRow).abs() == 2) {
      int midRow = fromRow + (toRow - fromRow) ~/ 2;
      int midCol = fromCol + (toCol - fromCol) ~/ 2;
      board[midRow][midCol] = 0;
    }

    if ((piece == 1 && toRow == 0) || (piece == 2 && toRow == 7)) {
      board[toRow][toCol] = piece + 2;
    }

    _checkWinner();
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    return true;
  }

  void makeComputerMove() {
    List<Map<String, int>> moves = _getAllValidMoves(2);
    if (moves.isEmpty) return;
    
    // Prioritize captures
    List<Map<String, int>> captureMoves = moves.where((move) {
      return (move['toRow']! - move['fromRow']!).abs() == 2;
    }).toList();
    
    if (captureMoves.isNotEmpty) {
      var move = captureMoves[Random().nextInt(captureMoves.length)];
      makeMove(move['fromRow']!, move['fromCol']!, move['toRow']!, move['toCol']!);
      return;
    }
    
    // Prioritize king promotion
    List<Map<String, int>> promotionMoves = moves.where((move) {
      return move['toRow'] == 7 && board[move['fromRow']!][move['fromCol']!] == 2;
    }).toList();
    
    if (promotionMoves.isNotEmpty) {
      var move = promotionMoves[Random().nextInt(promotionMoves.length)];
      makeMove(move['fromRow']!, move['fromCol']!, move['toRow']!, move['toCol']!);
      return;
    }
    
    // Make random move
    var move = moves[Random().nextInt(moves.length)];
    makeMove(move['fromRow']!, move['fromCol']!, move['toRow']!, move['toCol']!);
  }

  List<Map<String, int>> _getAllValidMoves(int player) {
    List<Map<String, int>> moves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int piece = board[row][col];
        if (piece != 0 && (piece == player || piece == player + 2)) {
          for (int toRow = 0; toRow < 8; toRow++) {
            for (int toCol = 0; toCol < 8; toCol++) {
              if (isValidMove(row, col, toRow, toCol)) {
                moves.add({
                  'fromRow': row,
                  'fromCol': col,
                  'toRow': toRow,
                  'toCol': toCol,
                });
              }
            }
          }
        }
      }
    }
    return moves;
  }

  int getPieceCount(int player) {
    int count = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int piece = board[row][col];
        if (piece == player || piece == player + 2) count++;
      }
    }
    return count;
  }

  void _checkWinner() {
    bool player1HasPieces = false;
    bool player2HasPieces = false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        int piece = board[row][col];
        if (piece == 1 || piece == 3) player1HasPieces = true;
        if (piece == 2 || piece == 4) player2HasPieces = true;
      }
    }

    if (!player1HasPieces) winner = 2;
    if (!player2HasPieces) winner = 1;
  }
}