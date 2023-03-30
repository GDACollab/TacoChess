extends GutTest;

var _whiteKing;
var _whiteQueensideRook;
var _whiteKingsideRook;

func before_each():
	Chessboard.ClearBoard();
	_whiteKing = Chessboard.GetPiece(Vector2(4, 0));
	_whiteQueensideRook = Chessboard.GetPiece(Vector2(0, 0));
	_whiteKingsideRook = Chessboard.GetPiece(Vector2(7, 0));
	
	Chessboard.SetPiece(Vector2(1, 0));
	Chessboard.SetPiece(Vector2(2, 0));
	Chessboard.SetPiece(Vector2(3, 0));
	Chessboard.SetPiece(Vector2(5, 0));
	Chessboard.SetPiece(Vector2(6, 0));

func test_pieces_are_right():
	assert_true(_whiteKing is Logic.King);
	assert_true(_whiteQueensideRook is Logic.Rook);
	assert_true(_whiteKingsideRook is Logic.Rook);

func test_can_castle():
	pass

func test_cant_castle_after_rook_move():
	pass

func test_cant_castle_with_pieces_between():
	pass

func test_cant_castle_after_king_move():
	pass
