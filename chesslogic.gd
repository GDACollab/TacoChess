class_name Logic;

static func update_game_board(moved_piece: Chessboard.Piece):
	# Moving one piece affects a whole bunch of what squares are or aren't threatened:
	Chessboard.threatened_squares = [[], []];
	
	var piece_valid_moves = [0, 0];
	var game_state = Chessboard.GameState.new();
	for i in range(8):
		for j in range(8):
			var piece = Chessboard.GetPiece(Vector2(i, j));
			if piece != null:
				if piece != moved_piece && piece.side == moved_piece.side:
					if piece is Pawn && (piece.pawn_move_state == Pawn.MoveState.MOVED_TWO):
						piece.pawn_move_state = Pawn.MoveState.PLAY;
				var possible_check = update_piece_threatened_squares(piece);
				if possible_check != null:
					game_state.in_check = possible_check;
					game_state.type = Chessboard.GameState.Type.CHECK;
	if game_state.in_check != null && len(game_state.in_check.get_possible_moves()) == 0:
		game_state.type = Chessboard.GameState.Type.CHECKMATE;
	Chessboard.current_game_state = game_state;
	return game_state;

static func update_piece_threatened_squares(piece : Chessboard.Piece) -> Chessboard.Piece:
	var threatened_arr : Array = Chessboard.threatened_squares[piece.side];
	var moves = [];
	if piece.type == Chessboard.Piece.Type.PAWN:
		moves = piece.get_pawn_threatened_squares();
	else:
		moves = piece.move_evaluation();
	
	var check = null;
	for move in moves:
		if contains_pos(threatened_arr, move.position).size() == 0:
			threatened_arr.append({"pos": move.position, "piece": piece});
			var threatened_piece = Chessboard.GetPiece(move.position);
			if threatened_piece != null && threatened_piece.side != piece.side && threatened_piece is King:
				check = threatened_piece;
	return check;

static func within_bounds(pos: Vector2) -> bool:
	return pos.x >= 0 && pos.x <= 7 && pos.y >= 0 && pos.y <= 7;

static func contains_pos(threatened_arr : Array, pos: Vector2) -> Dictionary:
	for t in threatened_arr:
		var p = t["pos"];
		if p.x == pos.x && p.y == pos.y:
			return t;
	return {};

# Is the king behind the threatened chesspiece?
static func king_short_raycast(threatener: Chessboard.Piece, threatened: Chessboard.Piece) -> bool:
	var direction = threatened.position - threatener.position;
	var normal = direction.normalized();
	var unit = Vector2(round(normal.x), round(normal.y));
	var i = threatened.position + unit;
	while within_bounds(i):
		var piece = Chessboard.GetPiece(i);
		if piece != null:
			return piece.type == Chessboard.Piece.Type.KING && piece.side == threatened.side; 
		i += unit;
	return false;

# A last-ditch effort to ensure move legality. Right now only used to detect if the king is pinned.
# Scenario: Piece is blocking a sliding piece, preventing check of the king.
# Only possible with sliding pieces: Rook, Queen, or Bishop.
# This is a hack to avoid re-writing all of the chess logic. But if you decide to re-write the chess logic, use https://www.chessprogramming.org
static func get_legal_moves(piece: Chessboard.Piece, arr : Array[Chessboard.Move]) -> Array[Chessboard.Move]:
	# So, are we currently under threat by a Rook, Queen, or Bishop?
	# And does that threat apply to the king?
	var opposing_threat = Chessboard.threatened_squares[abs(1 - piece.side)];
	var threatened = contains_pos(opposing_threat, piece.position);
	if threatened.size() > 0 && piece.type != Chessboard.Piece.Type.KING:
		var threatening_piece = threatened["piece"];
		var quick_test = threatening_piece.type == Chessboard.Piece.Type.BISHOP || threatening_piece.type == Chessboard.Piece.Type.ROOK || threatening_piece.type == Chessboard.Piece.Type.QUEEN;
		if (quick_test && king_short_raycast(threatening_piece, piece)):
			# Because we're protecting the king directly, we need to nix anything except a direct attack:
			for move in arr:
				if move.position == threatening_piece.position:
					return [move];
			return [];
	return arr;

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
	
	func get_pawn_threatened_squares() -> Array[Chessboard.Move]:
		var move_list : Array[Chessboard.Move] = [];
		
		var move_dir = get_move_dir();
		var cap_pos = self.position + Vector2(1, move_dir);
		var piece = Chessboard.GetPiece(cap_pos);
		if Logic.within_bounds(cap_pos) && piece == null:
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		cap_pos -= Vector2(2, 0);
		piece = Chessboard.GetPiece(cap_pos);
		if Logic.within_bounds(cap_pos) && piece == null:
			var cap = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		return move_list;
	
	func move_evaluation() -> Array[Chessboard.Move]:
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
			
			# We can only move double if there's not a piece blocking the way, so nested into the above if:
			var move_double = self.position + Vector2(0, 2 * move_dir);
			if self.pawn_move_state == MoveState.START and !(Chessboard.GetPiece(move_double)):
				var m1 = Chessboard.Move.new(Chessboard.Move.Type.MOVE, move_double);
				m1.execute = self.pawn_move.bind(move_double, MoveState.MOVED_TWO);
				move_list.append(m1);
		
		# Check captures:
		var cap_pos = self.position + Vector2(1, move_dir);
		var to_cap = Chessboard.GetPiece(cap_pos);
		if to_cap != null or self.check_en_passant(cap_pos):
			var type = Chessboard.Move.Type.CAPTURE;
			if (to_cap != null && to_cap.side == self.side):
				type = Chessboard.Move.Type.PROTECT;
			var cap = Chessboard.Move.new(type, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		cap_pos -= Vector2(2, 0);
		to_cap = Chessboard.GetPiece(cap_pos);
		if to_cap != null or self.check_en_passant(cap_pos):
			var type = Chessboard.Move.Type.CAPTURE;
			if (to_cap != null && to_cap.side == self.side):
				type = Chessboard.Move.Type.PROTECT;
			var cap = Chessboard.Move.new(type, cap_pos);
			cap.execute = self.pawn_move.bind(cap_pos);
			move_list.append(cap);
		return move_list;

class Rook extends Chessboard.Piece:
	enum CastleState {START, PLAY};
	var castle_state;
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		castle_state = CastleState.START;
		super(Chessboard.Piece.Type.ROOK, side, position);
	
	func update_castle_state(pos: Vector2) -> Chessboard.GameState:
		self.castle_state = CastleState.PLAY;
		return self.basic_move(pos);

	func move_evaluation() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		moves.append_array(self.raycast(Vector2(0, 1), self.update_castle_state));
		moves.append_array(self.raycast(Vector2(0, -1), self.update_castle_state));
		moves.append_array(self.raycast(Vector2(1, 0), self.update_castle_state));
		moves.append_array(self.raycast(Vector2(-1, 0), self.update_castle_state));
		return moves;

class Knight extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.KNIGHT, side, position);
	
	func gen_knight_move(pos : Vector2) -> Chessboard.Move:
		if !Logic.within_bounds(pos):
			return null;
			
		var piece = Chessboard.GetPiece(pos);
		var move : Chessboard.Move;
		if piece == null:
			move = Chessboard.Move.new(Chessboard.Move.Type.MOVE, pos);
			move.execute = self.basic_move.bind(pos);
		elif piece.side != self.side:
			move = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, pos);
			move.execute = self.basic_move.bind(pos);
		else:
			move = Chessboard.Move.new(Chessboard.Move.Type.PROTECT, pos);
		return move;
	
	func move_evaluation() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		
		for i in range(-2, 3):
			if i == 0:
				continue;
			var mul = 2;
			if i % 2 == 0:
				mul = 0.5;
			
			var move1 = gen_knight_move(self.position + Vector2(i, i * mul));
			if move1 != null:
				moves.append(move1);
			var move2 = gen_knight_move(self.position + Vector2(i, i * -mul));
			if move2 != null:
				moves.append(move2);
		return moves;

class Bishop extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.BISHOP, side, position);
	
	func move_evaluation() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		moves.append_array(self.raycast(Vector2(-1, -1)));
		moves.append_array(self.raycast(Vector2(-1, 1)));
		moves.append_array(self.raycast(Vector2(1, 1)));
		moves.append_array(self.raycast(Vector2(1, -1)));
		return moves;

class Queen extends Chessboard.Piece:
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.QUEEN, side, position);
	
	func move_evaluation() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		moves.append_array(self.raycast(Vector2(0, -1)));
		moves.append_array(self.raycast(Vector2(-1, -1)));
		moves.append_array(self.raycast(Vector2(-1, 0)));
		moves.append_array(self.raycast(Vector2(-1, 1)));
		moves.append_array(self.raycast(Vector2(0, 1)));
		moves.append_array(self.raycast(Vector2(1, 1)));
		moves.append_array(self.raycast(Vector2(1, 0)));
		moves.append_array(self.raycast(Vector2(1, -1)));
		return moves;

class King extends Chessboard.Piece:
	enum MoveState {START, PLAY};
	var move_state = MoveState.START;
	func _init(side: Chessboard.Piece.Side, position: Vector2):
		super(Chessboard.Piece.Type.KING, side, position);
	
	func king_move(pos: Vector2) -> Chessboard.GameState:
		self.move_state = MoveState.PLAY;
		return self.basic_move(pos);
	
	func get_king_move(offset : Vector2) -> Chessboard.Move:
		var new_pos = self.position + offset;
		if Logic.within_bounds(new_pos) && !self.get_in_check(new_pos):
			var piece = Chessboard.GetPiece(new_pos);
			if piece != null && piece.side != self.side:
				var move = Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, new_pos);
				move.execute = self.king_move.bind(new_pos);
				return move;
			elif piece == null:
				var move = Chessboard.Move.new(Chessboard.Move.Type.MOVE, new_pos);
				move.execute = self.king_move.bind(new_pos);
				return move;
		return null;
	
	func get_possible_castle(rook : Vector2) -> Chessboard.Move:
		var rook_piece = Chessboard.GetPiece(rook);
		if rook_piece != null && rook_piece is Rook && rook_piece.castle_state == Rook.CastleState.START:
			var dir = rook - self.position;
			var unit = dir / dir.length();
			
			for i in range(self.position.x + unit.x, rook.x, unit.x):
				if Chessboard.GetPiece(Vector2(i, self.position.y)) != null:
					return null;
			
			var offset = self.position + 2 * unit;
			var move = Chessboard.Move.new(Chessboard.Move.Type.CASTLE, offset);
			move.execute = self.king_move.bind(offset);
			return move;
		return null;
	
	func get_in_check(pos: Vector2 = self.position) -> bool:
		return Logic.contains_pos(Chessboard.threatened_squares[abs(1 - self.side)], pos).size() > 0;
	
	func move_evaluation() -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		for i in range(-1, 2):
			for j in range(-1, 2):
				if i == 0 && j == 0:
					continue;
				var possible = get_king_move(Vector2(i, j));
				if possible != null:
					moves.append(possible);
		
		# Castling:
		if self.move_state == MoveState.START && !self.get_in_check():
			var queenside = self.get_possible_castle(Vector2(0, self.position.y));
			if queenside != null:
				moves.append(queenside);
			
			var kingside = self.get_possible_castle(Vector2(7, self.position.y));
			if kingside != null:
				moves.append(kingside);
			
		return moves;
