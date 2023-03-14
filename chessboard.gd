extends Node

class GameState:
	# Play means continue as normal, Draw means both sides have lost, Check means a side is in danger of losing, Checkmate means a side has lost.
	enum Type {PLAY, DRAW, CHECK, CHECKMATE};
	var type : Chessboard.GameState.Type;
	# null if there's currently no piece in check.
	# If the type is CHECKMATE, then this side has lost:
	var inCheck : Chessboard.Piece;


# Given by get_possible_moves:
class Move:
	enum Type {MOVE, CAPTURE, CASTLE}
	var type : Chessboard.Move.Type;
	var position : Vector2;
	# Perform the actual move and update Chessboard. Will also return GameState to tell you important information about the game (has a side won? Lost? Is there a draw?)
	func execute() -> Chessboard.GameState:
		return GameState.new();

class Piece:
	enum Side {WHITE, BLACK}
	enum Type {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}
	var type : Chessboard.Piece.Type;
	var side : Chessboard.Piece.Side;
	var position : Vector2;
	static func new_piece(_type : Chessboard.Piece.Type = Type.PAWN, _side: Chessboard.Piece.Side = Side.WHITE, _pos: Vector2 = Vector2.ZERO):
		var p = Piece.new();
		p.type = _type;
		p.side = _side;
		p.position = _pos;
		return p;
	func get_possible_moves() -> Array[Chessboard.Move]:
		return [];

var _board : Array[Chessboard.Piece] = [];

# Also works for clearing a piece, since it just sets it to null.
func SetPiece(pos : Vector2, piece : Piece = null):
	_board[pos.x + pos.y * 8] = piece;

# This is required because en passant needs piece history:
func MovePiece(pos : Vector2, newPos : Vector2):
	_board[newPos.x + newPos.y * 8] = _board[pos.x + pos.y * 8];
	SetPiece(pos);

func DebugPrintBoard():
	# Invert the chessboard since white shows up first:
	for col in range(7, -1, -1):
		var row_str = "";
		for row in range(8):
			if row == 0:
				row_str += "|";
			if _board[row + col * 8] != null:
				var type = Chessboard.Piece.Type.keys()[_board[row + col * 8].type].substr(0, 2);
				var color = Chessboard.Piece.Side.keys()[_board[row + col * 8].side][0];
				row_str += (color.to_lower() + type);
			else:
				if (col + row) % 2:
					row_str += "▓▓▓";
				else:
					row_str += "░░░";
			row_str += "|";
		print(row_str);

func _ready():
	_board.resize(64);
	ClearBoard();
	DebugPrintBoard();

func ClearBoard():
	var layout = [Piece.Type.ROOK, Piece.Type.KNIGHT, Piece.Type.BISHOP, Piece.Type.QUEEN, Piece.Type.KING, Piece.Type.BISHOP, Piece.Type.KNIGHT, Piece.Type.ROOK];
	for i in range(8):
		SetPiece(Vector2(i, 1), Piece.new_piece(Piece.Type.PAWN, Piece.Side.WHITE, Vector2(i, 1)));
		SetPiece(Vector2(i, 6), Piece.new_piece(Piece.Type.PAWN, Piece.Side.BLACK, Vector2(i, 6)));
		
		SetPiece(Vector2(i, 0), Piece.new_piece(layout[i], Piece.Side.WHITE, Vector2(i, 0)));
		SetPiece(Vector2(i, 7), Piece.new_piece(layout[i], Piece.Side.BLACK, Vector2(i, 7)));
