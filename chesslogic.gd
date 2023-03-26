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
	
	func pawn_move(pos : Vector2, next_state : MoveState = MoveState.PLAY) -> Chessboard.GameState:
		self.pawn_move_state = next_state;
		return self.basic_move(pos);
		
	func get_possible_moves() -> Array[Chessboard.Move]:
		var move_list : Array[Chessboard.Move] = [];
		
		var move_dir = get_move_dir();
		var move_up = self.position + Vector2(0, move_dir);
		if !(Chessboard.GetPiece(move_up)):
			var type = Chessboard.Move.Type.MOVE;
			if int(move_up.y) % 8 == 0:
				type = Chessboard.Move.Type.PROMOTION;
			var m = Chessboard.Move.new(type,  move_up);
			m.execute = self.pawn_move.bind(move_up);
			move_list.append(m);
		
		var move_double = self.position + Vector2(0, 2 * move_dir);
		if self.pawn_move_state == MoveState.START and !(Chessboard.GetPiece(move_double)):
			var m1 = Chessboard.Move.new(Chessboard.Move.Type.MOVE, move_double);
			m1.execute = self.pawn_move.bind(move_double, MoveState.MOVED_TWO);
			move_list.append(m1);
			
			move_list[0].execute = self.pawn_move.bind(move_up, MoveState.MOVED_ONE);
		
		# Check captures:
		var cap_pos = self.position + Vector2(1, move_dir);
		if self.check_capture(cap_pos):
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		cap_pos -= Vector2(2, 0);
		if self.check_capture(cap_pos):
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		return move_list;
