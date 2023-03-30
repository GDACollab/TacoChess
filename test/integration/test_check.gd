extends GutTest;

func before_each():
	Chessboard.ClearBoard();
	Chessboard.SetPiece(Vector2(4, 1));
	Chessboard.SetPiece(Vector2(5, 0));
	Chessboard.SetPiece(Vector2(3, 0));

func set_piece(piece : GDScript, pos : Vector2 = Vector2(4, 2), side : Chessboard.Piece.Side = Chessboard.Piece.Side.BLACK):
	var p = piece.new(side, pos);
	Chessboard.SetPiece(pos, p);
	Logic.update_game_board(p);

func test_regular_check():
	set_piece(Logic.Queen);
	assert_eq(Chessboard.current_game_state.type, Chessboard.GameState.Type.CHECK);
	assert_eq(Chessboard.current_game_state.in_check.position, Vector2(4, 0));
	assert_eq(Chessboard.current_game_state.in_check.type, Chessboard.Piece.Type.KING);

func test_checkmate():
	set_piece(Logic.Queen);
	set_piece(Logic.Queen, Vector2(3, 0), Chessboard.Piece.Side.WHITE);
	set_piece(Logic.Bishop, Vector2(5, 0), Chessboard.Piece.Side.WHITE);
	assert_eq(Chessboard.current_game_state.type, Chessboard.GameState.Type.CHECKMATE);
	assert_eq(Chessboard.current_game_state.in_check.position, Vector2(4, 0));
	assert_eq(Chessboard.current_game_state.in_check.type, Chessboard.Piece.Type.KING);

func test_legal_check_limits_moves():
	set_piece(Logic.Queen);
	set_piece(Logic.Rook, Vector2(4, 1), Chessboard.Piece.Side.WHITE);
	assert_true(PieceLogicTest.assert_move_arr_eq(Chessboard.GetPiece(Vector2(4, 1)).get_possible_moves(), [Chessboard.Move.new(Chessboard.Move.Type.CAPTURE, Vector2(4, 2))]), "White Rook Cannot Place In Check");

func test_legal_check_limits_moves_pawn():
	set_piece(Logic.Queen);
	set_piece(Logic.Rook, Vector2(3, 2));
	set_piece(Logic.Pawn, Vector2(4, 1), Chessboard.Piece.Side.WHITE);
	assert_eq(Chessboard.GetPiece(Vector2(4, 1)).get_possible_moves(), []);
