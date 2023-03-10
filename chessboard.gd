extends Node

enum Side {WHITE, BLACK}
enum Type {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}

class Piece:
	var type;
	var side;
	static func new_piece(_type : Chessboard.Type = Type.PAWN, _side: Chessboard.Side = Side.WHITE):
		var p = Piece.new();
		p.type = _type;
		p.side = _side;
		return p;

var _board : Array[Chessboard.Piece] = [];

# Also works for clearing a piece, since it just sets it to null.
func SetPiece(x : int, y : int, piece : Piece = null):
	_board[x + y * 8] = piece;

# This is required because en passant requires piece history:
func MovePiece(x: int, y : int, newX: int, newY: int):
	_board[newX + newY * 8] = _board[x + y * 8];
	SetPiece(x, y);

func DebugPrintBoard():
	# Invert the chessboard since white shows up first:
	for col in range(7, -1, -1):
		var row_str = "";
		for row in range(8):
			if _board[row + col * 8] != null:
				var type = Chessboard.Type.keys()[_board[row + col * 8].type].substr(0, 2);
				var color = Chessboard.Side.keys()[_board[row + col * 8].side][0];
				row_str += (color.to_lower() + type);
			else:
				if (col + row) % 2:
					row_str += "▓▓▓";
				else:
					row_str += "░░░";
		print(row_str);

func _ready():
	_board.resize(64);
	clear();
	DebugPrintBoard();

func clear():
	var layout = [Type.ROOK, Type.KNIGHT, Type.BISHOP, Type.QUEEN, Type.KING, Type.BISHOP, Type.KNIGHT, Type.ROOK];
	for i in range(8):
		SetPiece(i, 1, Piece.new_piece(Type.PAWN, Side.WHITE));
		SetPiece(i, 6, Piece.new_piece(Type.PAWN, Side.BLACK));
		
		SetPiece(i, 0, Piece.new_piece(layout[i], Side.WHITE));
		SetPiece(i, 7, Piece.new_piece(layout[i], Side.BLACK));
