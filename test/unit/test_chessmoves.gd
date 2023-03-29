extends GutTest;
class_name PieceLogicTest;

static func assert_move_eq(move1 : Chessboard.Move, move2: Chessboard.Move) -> bool:
	if move1.type != move2.type:
		print(str(move2.type) + " type != " + str(move2.type));
		return false;
	if move1.position != move2.position:
		print(str(move1.position) + " position != " + str(move2.position));
		return false;
	return true;

static func assert_move_arr_eq(arr1 : Array[Chessboard.Move], arr2 : Array[Chessboard.Move]) -> bool:
	if len(arr1) != len(arr2):
		print("Not equal length");
		return false;
	for i in range(len(arr1)):
		if !(assert_move_eq(arr1[i], arr2[i])):
			print(str(i) + " not equal");
			return false;
	return true;

class TestPawn:
	extends GutTest;
	
	var _whitePawn = null;
	var _blackPawn = null;
	func before_each():
		Chessboard.ClearBoard();
		_whitePawn = Chessboard.GetPiece(Vector2(0, 1));
		_blackPawn = Chessboard.GetPiece(Vector2(1, 6));
	
	func get_move_forward(pawn : Chessboard.Piece, by : int = 1):
		return Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(pawn.position.x, pawn.position.y + by));
	
	func test_is_pawn():
		assert_true(_whitePawn is Logic.Pawn);
		assert_true(_blackPawn is Logic.Pawn);
		assert_eq(_whitePawn.side, Chessboard.Piece.Side.WHITE);
		assert_eq(_blackPawn.side, Chessboard.Piece.Side.BLACK);
	
	func test_can_move_start():
		var t = get_move_forward(_whitePawn);
		var m = _whitePawn.get_possible_moves();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn), get_move_forward(_whitePawn, 2)]), "White Pawn Moves");
		assert_true(PieceLogicTest.assert_move_arr_eq(_blackPawn.get_possible_moves(), [get_move_forward(_blackPawn, -1), get_move_forward(_blackPawn, -2)]), "Black Pawn Moves");
		
		m[0].execute.call();
		_blackPawn.get_possible_moves()[0].execute.call();
		assert_eq(_whitePawn.position, Vector2(0, 2));
		assert_eq(_blackPawn.position, Vector2(1, 5));
	
	func test_can_no_longer_move_two():
		_whitePawn.get_possible_moves()[0].execute.call();
		_blackPawn.get_possible_moves()[1].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn)]), "White Pawn Moves");
		assert_true(PieceLogicTest.assert_move_arr_eq(_blackPawn.get_possible_moves(), [get_move_forward(_blackPawn, -1)]), "Black Pawn Moves");
	
	func test_can_promote():
		Chessboard.SetPiece(Vector2(0, 6));
		Chessboard.SetPiece(Vector2(0, 7));
		while (_whitePawn.position.y < 6):
			_whitePawn.get_possible_moves()[0].execute.call();
		# Should be promotion
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [Chessboard.Move.new(Chessboard.Move.Type.PROMOTION, Vector2(0, 7)), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 7))]), "White Pawn Move Promote");
	
	# Google "Google En Passant"
	func test_can_en_passant():
		while (_whitePawn.position.y < 4):
			_whitePawn.get_possible_moves()[0].execute.call();
		_blackPawn.get_possible_moves()[1].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 5))]), "White Pawn Can En Passant");
	
	func test_cant_en_passant_after():
		while (_whitePawn.position.y < 4):
			_whitePawn.get_possible_moves()[0].execute.call();
		_blackPawn.get_possible_moves()[1].execute.call();
		Chessboard.GetPiece(Vector2(2, 6)).get_possible_moves()[0].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn)]), "White Pawn Can Only Move Up After En Passant Opportunity");
	
	func test_can_capture():
		_whitePawn.get_possible_moves()[1].execute.call();
		_blackPawn.get_possible_moves()[1].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 4))]), "White Pawn Can Capture");
		
		assert_true(PieceLogicTest.assert_move_arr_eq(_blackPawn.get_possible_moves(), [get_move_forward(_blackPawn, -1), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(0, 3))]), "Black Pawn Can Capture");
	
	func test_blocked():
		_whitePawn.get_possible_moves()[1].execute.call();
		Chessboard.GetPiece(Vector2(0, 6)).get_possible_moves()[1].execute.call();
		assert_eq(_whitePawn.get_possible_moves(), []);
	
	func test_threatened():
		assert_true(PieceLogicTest.assert_move_arr_eq(_whitePawn.get_pawn_threatened_squares(), [Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 2))]), "White Pawn Threatened Squares");
		assert_true(PieceLogicTest.assert_move_arr_eq(_blackPawn.get_pawn_threatened_squares(), [Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(2, 5)), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(0, 5))]), "Black Pawn Threatened Squares");

class TestRook:
	extends GutTest;
	
	var _whiteRook = null;
	func before_each():
		Chessboard.ClearBoard();
		_whiteRook = Chessboard.GetPiece(Vector2(0, 0));
		Chessboard.SetPiece(Vector2(0, 1));
	
	func test_is_rook():
		assert_true(_whiteRook is Logic.Rook);
	
	func test_rook_trapped():
		Chessboard.SetPiece(Vector2(0, 1), Logic.Pawn.new(Chessboard.Piece.Side.WHITE, Vector2(1, 0)));
		assert_eq(_whiteRook.get_possible_moves(), []);
	
	func move_in_dir(pos: Vector2, vector: Vector2, squares: Array[int]) -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		for square in squares:
			moves.append(Chessboard.Move.new(Chessboard.Move.Type.MOVE, pos + vector * square));
		return moves;
	
	func test_rook_move_up_and_capture():
		var moves = move_in_dir(Vector2(0, 0), Vector2(0, 1), [1, 2, 3, 4, 5]);
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(0, 6)));
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteRook.get_possible_moves(), moves), "Rook Move Up And Capture");
	
	func test_four_way_movement():
		_whiteRook.get_possible_moves()[2].execute.call();
		_whiteRook.get_possible_moves()[6].execute.call();
		var moves = move_in_dir(Vector2(1, 0), Vector2(0, 1), [4, 5]);
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 6)));
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(1, 2)));
		moves.append_array(move_in_dir(Vector2(0, 3), Vector2(1, 0), [2, 3, 4, 5, 6, 7, 0]));
		var pos = _whiteRook.get_possible_moves();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteRook.get_possible_moves(), moves), "Rook Four Way");

class TestKnight:
	extends GutTest;
	
	var _whiteKnight = null;
	func before_each():
		Chessboard.ClearBoard();
		_whiteKnight = Chessboard.GetPiece(Vector2(1, 0));
	
	func get_move(pos: Vector2, type: Chessboard.Move.Type = Chessboard.Move.Type.MOVE) -> Chessboard.Move:
		return Chessboard.Move.new(type, pos);
	
	func test_is_knight():
		assert_true(_whiteKnight is Logic.Knight);
	
	func test_hop_over():
		var moves : Array[Chessboard.Move] = [get_move(Vector2(0, 2)), get_move(Vector2(2, 2))];
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKnight.get_possible_moves(), moves), "Knight Start");
	
	func test_full_diag():
		_whiteKnight.get_possible_moves()[1].execute.call();
		var moves : Array[Chessboard.Move] = [get_move(Vector2(0, 3)), get_move(Vector2(1, 0)), get_move(Vector2(1, 4)), get_move(Vector2(3, 4)), get_move(Vector2(4, 3))];
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKnight.get_possible_moves(), moves), "Knight Move 1");
		_whiteKnight.get_possible_moves()[3].execute.call();
		moves = [get_move(Vector2(1, 3)), get_move(Vector2(1, 5)), get_move(Vector2(2, 2)), get_move(Vector2(2, 6), Chessboard.Move.Type.CAPTURE), get_move(Vector2(4, 6), Chessboard.Move.Type.CAPTURE), get_move(Vector2(4, 2)), get_move(Vector2(5, 5)), get_move(Vector2(5, 3))];
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKnight.get_possible_moves(), moves), "Knight Move 2");

class TestBishop:
	extends GutTest;
	
	var _whiteBishop = null;
	var _blackBishop = null;
	
	func before_each():
		Chessboard.ClearBoard();
		_whiteBishop = Chessboard.GetPiece(Vector2(2, 0));
		_blackBishop = Chessboard.GetPiece(Vector2(5, 7));
	
	func test_is_bishop():
		assert_true(_whiteBishop is Logic.Bishop);
		assert_true(_blackBishop is Logic.Bishop);
	
	func test_is_trapped():
		assert_eq(_whiteBishop.get_possible_moves(), []);
		assert_eq(_blackBishop.get_possible_moves(), []);
	
	func get_move(pos: Vector2, type: Chessboard.Move.Type = Chessboard.Move.Type.MOVE) -> Chessboard.Move:
		return Chessboard.Move.new(type, pos);
	
	func test_paths_open():
		Chessboard.SetPiece(Vector2(3, 1));
		Chessboard.SetPiece(Vector2(1, 1));
		Chessboard.SetPiece(Vector2(4, 6));
		Chessboard.SetPiece(Vector2(6, 6));
		
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteBishop.get_possible_moves(), [get_move(Vector2(1, 1)), get_move(Vector2(0, 2)), get_move(Vector2(3, 1)), get_move(Vector2(4, 2)), get_move(Vector2(5, 3)), get_move(Vector2(6, 4)), get_move(Vector2(7, 5))]), "White Bishop Paths");
		
		assert_true(PieceLogicTest.assert_move_arr_eq(_blackBishop.get_possible_moves(), [get_move(Vector2(4, 6)), get_move(Vector2(3, 5)), get_move(Vector2(2, 4)), get_move(Vector2(1, 3)), get_move(Vector2(0, 2)), get_move(Vector2(6, 6)), get_move(Vector2(7, 5))]), "Black Bishop Paths");

class TestQueen:
	extends GutTest;
	
	var _whiteQueen = null;
	
	func before_each():
		Chessboard.ClearBoard();
		_whiteQueen = Chessboard.GetPiece(Vector2(3, 0));
		
	func test_is_queen():
		assert_true(_whiteQueen is Logic.Queen);
		
	
	func test_is_trapped():
		assert_eq(_whiteQueen.get_possible_moves(), []);
	
	func move_in_dir(pos: Vector2, vector: Vector2, squares: Array[int]) -> Array[Chessboard.Move]:
		var moves : Array[Chessboard.Move] = [];
		for square in squares:
			moves.append(Chessboard.Move.new(Chessboard.Move.Type.MOVE, pos + vector * square));
		return moves;
	
	func test_move_forward_only():
		Chessboard.SetPiece(Vector2(3, 1));
		var moves : Array[Chessboard.Move] = [];
		moves.append_array(move_in_dir(Vector2(3, 0), Vector2(0, 1), [1, 2, 3, 4, 5]));
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(3, 6)));
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteQueen.get_possible_moves(), moves), "Queen Can Move Forward");
	
	func test_full_move_range():
		Chessboard.SetPiece(Vector2(3, 1));
		_whiteQueen.get_possible_moves()[2].execute.call();
		var moves : Array[Chessboard.Move] = [];
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(0, -1), [1, 2, 3]));
		
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(2, 2)));
		
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(-1, 0), [1, 2, 3]));
		
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(-1, 1), [1, 2]));
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(0, 6)));
		
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(0, 1), [1, 2]));
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(3, 6)));
		
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(1, 1), [1, 2]));
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(6, 6)));
		
		moves.append_array(move_in_dir(Vector2(3, 3), Vector2(1, 0), [1, 2, 3, 4]));
		
		moves.append(Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(4, 2)));
		
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteQueen.get_possible_moves(), moves), "White Queen Full Move");

class TestKing:
	extends GutTest;
	
	var _whiteKing;
	
	func before_each():
		Chessboard.ClearBoard();
		_whiteKing = Chessboard.GetPiece(Vector2(4, 0));
	
	func test_is_king():
		assert_true(_whiteKing is Logic.King);
	
	func test_is_trapped():
		assert_eq(_whiteKing.get_possible_moves(), []);
	
	func get_move(pos: Vector2, type: Chessboard.Move.Type = Chessboard.Move.Type.MOVE) -> Chessboard.Move:
		return Chessboard.Move.new(type, pos);
	
	func test_can_move():
		Chessboard.SetPiece(Vector2(4, 1));
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(4, 1))]), "White King Move Up");
	
	func test_can_move_full():
		Chessboard.SetPiece(Vector2(4, 1));
		_whiteKing.get_possible_moves()[0].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 2)), get_move(Vector2(4, 0)), get_move(Vector2(4, 2)), get_move(Vector2(5, 2))]), "White King Move All But Sides");
		_whiteKing.get_possible_moves()[2].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 2)), get_move(Vector2(3, 3)), get_move(Vector2(4, 1)), get_move(Vector2(4, 3)), get_move(Vector2(5, 2)), get_move(Vector2(5, 3))]), "White King Move Still Limited");
		_whiteKing.get_possible_moves()[3].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 2)), get_move(Vector2(3, 3)), get_move(Vector2(3, 4)), get_move(Vector2(4, 2)), get_move(Vector2(4, 4)), get_move(Vector2(5, 2)), get_move(Vector2(5, 3)), get_move(Vector2(5, 4))]), "White King Move All");
	
	func test_cannot_place_self_in_check():
		Chessboard.SetPiece(Vector2(4, 1));
		_whiteKing.get_possible_moves()[0].execute.call();
		_whiteKing.get_possible_moves()[2].execute.call();
		_whiteKing.get_possible_moves()[3].execute.call();
		_whiteKing.get_possible_moves()[4].execute.call();
		assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 3)), get_move(Vector2(3, 4)), get_move(Vector2(4, 3)), get_move(Vector2(5, 3)), get_move(Vector2(5, 4))]), "White King Cannot Place Self In Check");
