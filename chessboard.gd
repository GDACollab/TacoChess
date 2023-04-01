extends Node
# If for whatever reason this is revisited, I would encourage you to go to: https://www.chessprogramming.org
# Which has a lot more information that I did not use when making this. It's a lot more interesting and focused on more efficient programming.
# Bitboard representation seems really cool.

var volume = 0.0;

# Because class_name doesn't work for singletons:
var logic = preload("res://chesslogic.gd");
# Two arrays, one represents the squares threatened by side 0 and 1 respectively (WHITE and BLACK).
var threatened_squares = [[], []];
var current_game_state : GameState = GameState.new();

class GameState:
	# Play means continue as normal, Draw means both sides have lost, Check means a side is in danger of losing, Checkmate means a side has lost.
	enum Type {PLAY, DRAW, CHECK, CHECKMATE};
	var type : Chessboard.GameState.Type = Type.PLAY;
	# null if there's currently no piece in check.
	# If the type is CHECKMATE, then this side has lost:
	var in_check : Chessboard.Piece;


# Given by get_possible_moves:
class Move:
	enum Type {MOVE, CAPTURE, PROTECT, CASTLE, PROMOTION}
	var type : Chessboard.Move.Type;
	var position : Vector2;
	func _init(_type: Chessboard.Move.Type, _position: Vector2):
		type = _type;
		position = _position;
	# Perform the actual move and update Chessboard. Will also return GameState to tell you important information about the game (has a side won? Lost? Is there a draw?)
	var execute: Callable; # Should return Chessboard.GameState

class Piece:
	enum Side {WHITE, BLACK}
	enum Type {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING}
	var type : Chessboard.Piece.Type;
	var side : Chessboard.Piece.Side;
	var position : Vector2 ;
	func _init(_type : Chessboard.Piece.Type = Type.PAWN, _side: Chessboard.Piece.Side = Side.WHITE, _pos: Vector2 = Vector2.ZERO):
		type = _type;
		side = _side;
		position = _pos;
	
	func move_evaluation() -> Array[Chessboard.Move]:
		return [];
	
	func get_possible_moves() -> Array[Chessboard.Move]:
		return Chessboard.logic.get_legal_moves(self, self.move_evaluation());
	
	func basic_move(pos: Vector2) -> Chessboard.GameState:
		Chessboard.MovePiece(self.position, pos);
		self.position = pos;
		return Chessboard.logic.update_game_board(self);
	
	func check_capture(pos : Vector2) -> bool:
		if Chessboard.logic.within_bounds(pos):
			var piece = Chessboard.GetPiece(pos);
			return piece != null && piece.side != self.side;
		else:
			return false;

	func raycast(ray: Vector2, execute: Callable = basic_move) -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		for i in range(1, 7):
			var new_pos = (ray * i) + self.position;
			if !Chessboard.logic.within_bounds(new_pos):
				break;
			var piece = Chessboard.GetPiece(new_pos);
			if piece == null:
				var move = Chessboard.Move.new(Chessboard.Move.Type.MOVE, new_pos);
				move.execute = execute.bind(new_pos);
				moves.append(move);
			else:
				if piece.side != self.side:
					var move = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, new_pos);
					move.execute = execute.bind(new_pos);
					moves.append(move);
				else:
					var move = Chessboard.Move.new(Chessboard.Move.Type.PROTECT, new_pos);
					moves.append(move);
				break;
		return moves;

var _board : Array[Chessboard.Piece] = [];

# Also works for clearing a piece, since it just sets it to null.
func SetPiece(pos : Vector2, piece : Piece = null):
	if logic.within_bounds(pos):
		_board[pos.x + pos.y * 8] = piece;

# This is required because en passant needs piece history:
func MovePiece(pos : Vector2, newPos : Vector2):
	SetPiece(newPos, _board[pos.x + pos.y * 8]);
	SetPiece(pos);

func GetPiece(pos : Vector2) -> Chessboard.Piece:
	if (pos.x >= 0 && pos.x <= 7 && pos.y >= 0 && pos.y <= 7):
		return _board[pos.x + pos.y * 8];
	else:
		return null;

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
	print("");

func _ready():
	_board.resize(64);
	ClearBoard();

func ClearBoard():
	_board.fill(null);
	
	var layout = [logic.Rook, logic.Knight, logic.Bishop, logic.Queen, logic.King, logic.Bishop, logic.Knight, logic.Rook];
	Move.new(Move.Type.PROMOTION, Vector2(0, 0));
	for i in range(8):
		SetPiece(Vector2(i, 1), logic.Pawn.new(Piece.Side.WHITE, Vector2(i, 1)));
		SetPiece(Vector2(i, 6), logic.Pawn.new(Piece.Side.BLACK, Vector2(i, 6)));
		
		SetPiece(Vector2(i, 0), layout[i].new(Piece.Side.WHITE, Vector2(i, 0)));
		SetPiece(Vector2(i, 7), layout[i].new(Piece.Side.BLACK, Vector2(i, 7)));
