extends GutTest

class TestPawn:
	extends GutTest
	
	var _whitePawn = null;
	var _blackPawn = null;
	func before_each():
		Chessboard.ClearBoard();
		_whitePawn = Chessboard.GetPiece(Vector2(0, 1));
		_blackPawn = Chessboard.GetPiece(Vector2(1, 6));
	
	func get_move_forward(pawn : Logic.Pawn, by : int = 1):
		return Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(pawn.x, pawn.y + by));
	
	func test_is_pawn():
		assert_typeof(_whitePawn, typeof(Logic.Pawn));
		assert_typeof(_blackPawn, typeof(Logic.Pawn));
	
	func test_can_move_start():
		assert_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn), get_move_forward(_whitePawn, 2)]);
		assert_eq(_blackPawn.get_possible_moves(), [get_move_forward(_blackPawn, -1), get_move_forward(_blackPawn, -2)]);
	
	func test_can_promote():
		Chessboard.SetPiece(Vector2(0, 6));
		while (_whitePawn.position.y < 6):
			_whitePawn.get_possible_moves()[0].execute();
		assert_eq(_whitePawn.get_possible_moves(), [Chessboard.Move.new(Chessboard.Move.Type.PROMOTION, Vector2(0, 7))]);
	
	# Google "Google En Passant"
	func test_can_en_passant():
		while (_whitePawn.position.y < 6):
			_whitePawn.get_possible_moves()[0].execute();
		_blackPawn.get_possible_moves()[1].execute();
		assert_eq(_whitePawn.get_possible_moves(), [Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 6))]);
	
	func test_can_capture():
		_whitePawn.get_possible_moves()[1].execute();
		_blackPawn.get_possible_moves()[1].execute();
		assert_eq(_whitePawn.get_possible_moves(), [get_move_forward(_whitePawn), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(1, 4))]);
		
		assert_eq(_blackPawn.get_possible_moves(), [get_move_forward(_blackPawn), Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(0, 3))]);
