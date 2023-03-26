extends Node
class_name Logic;

static func update_game_board():
	return Chessboard.GameState.new();

class Pawn extends Chessboard.Piece:
	enum MoveState {START, MOVED_TWO, MOVED_ONE, PLAY};
	var pawn_move_state : MoveState = MoveState.START;
	
	func _init(side : Chessboard.Piece.Side, position : Vector2):
		super(Chessboard.Piece.Type.PAWN, side, position);
	
	func get_move_dir():
		return ((self.side * -2) + 1);
		
	func get_possible_moves() -> Array[Chessboard.Move]:
		var move_dir = get_move_dir();
		var move_up = self.position + Vector2(0, move_dir);
		var m = Chessboard.Move.new(Chessboard.Move.Type.MOVE,  move_up);
		m.execute = self.basic_move.bind(move_up);
		
		var move_double = self.position + Vector2(0, 2 * move_dir);
		var m1 = Chessboard.Move.new(Chessboard.Move.Type.MOVE, move_double);
		m1.execute = self.basic_move.bind(move_double);
		return [m, m1];
