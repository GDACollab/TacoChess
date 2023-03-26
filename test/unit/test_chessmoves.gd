extends GutTest
class_name PieceLogicTest

static func assert_move_eq(move1 : Chessboard.Move, move2: Chessboard.Move) -> bool:
	if move1.type != move2.type:
		print(str(move2.type) + " type != " + str(move2.type));
		return false;
	if move1.position != move2.position:
		print(str(move1.position) + " position != " + str(move2.position));
		return false;
	return true;

static func assert_move_arr_eq(arr1 : Array, arr2 : Array) -> bool:
	if len(arr1) != len(arr2):
		print("Not equal length");
		return false;
	for i in range(len(arr1)):
		if !(assert_move_eq(arr1[i], arr2[i])):
			print(str(i) + " not equal");
			return false;
	return true;

class TestPawn:
	extends GutTest
	
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

class TestRook:
	extends GutTest
	
	var _whiteRook = null;
	func before_each():
		Chessboard.ClearBoard();
		_whiteRook = Chessboard.GetPiece(Vector2(0, 0));
		Chessboard.SetPiece(Vector2(1, 0));
	
	func test_is_rook():
		assert_true(_whiteRook is Logic.Rook);
	
	func test_rook_trapped():
		pass
