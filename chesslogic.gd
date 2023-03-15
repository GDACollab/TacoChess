extends Node

class RegularMove extends Chessboard.Move:
	func _init(_position : Vector2):
		super(Chessboard.Move.Type.MOVE, _position);
	func execute() -> Chessboard.GameState:
		# Update so that our piece has moved:
		return Chessboard.GameState.new();

class Pawn extends Chessboard.Piece:
	enum MoveState {START, MOVED_TWO, MOVED_ONE, PLAY};
	var pawn_move_state : MoveState = MoveState.START;
	func _init(side : Chessboard.Piece.Side, position : Vector2):
		super(Chessboard.Piece.Type.PAWN, side, position);
	func get_possible_moves() -> Array[Chessboard.Move]:
		
