extends GutTest

const logic = preload("res://chesslogic.gd");

func before_each():
	Chessboard.ClearBoard();

class TestPawn:
	extends GutTest
	
	var _pawn = null;
	func before_each():
		_pawn = Chessboard.GetPiece(Vector2(0, 1));
	
	func test_is_pawn():
		assert_typeof(_pawn, typeof(logic.Pawn));
	
	func test_can_move_start():
		assert_eq(_pawn.get_possible_moves(), [Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(0, 2)), Chessboard.Move.new(Chessboard.Move.Type.MOVE, Vector2(0, 3))]);
		pass
