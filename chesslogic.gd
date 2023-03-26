extends Node
class_name Logic;

static func update_game_board(moved_piece: Chessboard.Piece):
	for i in range(8):
		for j in range(8):
			var piece = Chessboard.GetPiece(Vector2(i, j));
			if piece != null && piece != moved_piece && piece.side == moved_piece.side:
				if piece is Pawn && (piece.pawn_move_state == Pawn.MoveState.MOVED_TWO):
					piece.pawn_move_state = Pawn.MoveState.PLAY;
	return Chessboard.GameState.new();

class Pawn extends Chessboard.Piece:
	enum MoveState {START, MOVED_TWO, PLAY};
	var pawn_move_state : MoveState = MoveState.START;
	
	func _init(side : Chessboard.Piece.Side, position : Vector2):
		super(Chessboard.Piece.Type.PAWN, side, position);
	
	func get_move_dir():
		return ((self.side * -2) + 1);
	
	func pawn_move(pos : Vector2, next_state : MoveState = MoveState.PLAY) -> Chessboard.GameState:
		self.pawn_move_state = next_state;
		return self.basic_move(pos);
	
	func check_en_passant(pos: Vector2) -> bool:
		var move_dir = get_move_dir();
		var past_pawn = Chessboard.GetPiece(pos - Vector2(0, move_dir));
		var is_pawn = past_pawn && past_pawn is Pawn;
		return is_pawn && past_pawn.side != self.side && past_pawn.pawn_move_state == MoveState.MOVED_TWO;
		
	func get_possible_moves() -> Array[Chessboard.Move]:
		var move_list : Array[Chessboard.Move] = [];
		
		var move_dir = get_move_dir();
		var move_up = self.position + Vector2(0, move_dir);
		if !(Chessboard.GetPiece(move_up)):
			var type = Chessboard.Move.Type.MOVE;
			# Are we near the edge of the board?
			if int(move_up.y) % 7 == 0:
				type = Chessboard.Move.Type.PROMOTION;
			var m = Chessboard.Move.new(type,  move_up);
			m.execute = self.pawn_move.bind(move_up);
			move_list.append(m);
		
		var move_double = self.position + Vector2(0, 2 * move_dir);
		if self.pawn_move_state == MoveState.START and !(Chessboard.GetPiece(move_double)):
			var m1 = Chessboard.Move.new(Chessboard.Move.Type.MOVE, move_double);
			m1.execute = self.pawn_move.bind(move_double, MoveState.MOVED_TWO);
			move_list.append(m1);
		
		# Check captures:
		var cap_pos = self.position + Vector2(1, move_dir);
		if self.check_capture(cap_pos) or self.check_en_passant(cap_pos):
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		cap_pos -= Vector2(2, 0);
		if self.check_capture(cap_pos) or self.check_en_passant(cap_pos):
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		return move_list;

class Rook extends Chessboard.Piece:
	enum CastleState {START, PLAY};
	var castle_state;
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		castle_state = CastleState.START;
		super(Chessboard.Piece.Type.ROOK, side, position);
	
	func rook_raycast():
		pass
	func get_possible_moves() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		return moves;

class Knight extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.KNIGHT, side, position);

class Bishop extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.BISHOP, side, position);

class King extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.KING, side, position);
	
class Queen extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.QUEEN, side, position);
