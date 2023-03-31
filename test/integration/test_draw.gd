extends GutTest;

func before_each():
	Chessboard.ClearBoard();

func test_quick_stalemate():
	for i in range(0, 8):
		for j in range(0, 2):
			Chessboard.SetPiece(Vector2(i, j));
	Chessboard.SetPiece(Vector2(0, 0), Logic.King.new(Chessboard.Piece.Side.WHITE, Vector2(0, 0)));
	Chessboard.SetPiece(Vector2(2, 1), Logic.Queen.new(Chessboard.Piece.Side.BLACK, Vector2(2, 1)));
	Logic.update_game_board(Chessboard.GetPiece(Vector2(2, 1)));
	assert_eq(Chessboard.current_game_state.type, Chessboard.GameState.Type.DRAW);
