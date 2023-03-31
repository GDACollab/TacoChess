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

func get_move(pos : Vector2, type: Chessboard.Move.Type = Chessboard.Move.Type.MOVE) -> Chessboard.Move:
	return Chessboard.Move.new(type, pos);

func test_pieces_are_right():
	assert_true(_whiteKing is Logic.King);
	assert_true(_whiteQueensideRook is Logic.Rook);
	assert_true(_whiteKingsideRook is Logic.Rook);

func test_can_castle():
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 0)), get_move(Vector2(5, 0)), get_move(Vector2(2, 0), Chessboard.Move.Type.CASTLE), get_move(Vector2(6, 0), Chessboard.Move.Type.CASTLE)]));

func test_cant_castle_after_rook_move():
	_whiteQueensideRook.get_possible_moves()[1].execute.call();
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 0)), get_move(Vector2(5, 0)), get_move(Vector2(6, 0), Chessboard.Move.Type.CASTLE)]));

func test_cant_castle_with_pieces_between():
	Chessboard.SetPiece(Vector2(6, 0), Logic.Pawn.new(Chessboard.Piece.Side.WHITE, Vector2(6, 0)));
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 0)), get_move(Vector2(5, 0)), get_move(Vector2(2, 0), Chessboard.Move.Type.CASTLE)]));
	Chessboard.SetPiece(Vector2(1, 0), Logic.Pawn.new(Chessboard.Piece.Side.WHITE, Vector2(1, 0)));
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 0)), get_move(Vector2(5, 0))]));

func test_cant_castle_after_king_move():
	_whiteKing.get_possible_moves()[1].execute.call();
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(4, 0)), get_move(Vector2(6, 0))]));

func test_cant_castle_in_check():
	var quick_rook = Logic.Rook.new(Chessboard.Piece.Side.BLACK, Vector2(4, 1))
	Chessboard.SetPiece(Vector2(4, 1), quick_rook);
	Logic.update_game_board(quick_rook);
	assert_true(PieceLogicTest.assert_move_arr_eq(_whiteKing.get_possible_moves(), [get_move(Vector2(3, 0)), get_move(Vector2(4, 1), Chessboard.Move.Type.CAPTURE), get_move(Vector2(5, 0))]));
