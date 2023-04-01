extends Node2D

const b_pawn_sprite = preload("res://ChessPieceSprites/black_pawn.png");
const b_rook_sprite = preload("res://ChessPieceSprites/black_rook.png");
const b_knight_sprite = preload("res://ChessPieceSprites/black_knight.png");
const b_bishop_sprite = preload("res://ChessPieceSprites/black_bishop.png");
const b_queen_sprite = preload("res://ChessPieceSprites/black_queen.png");
const b_king_sprite = preload("res://ChessPieceSprites/black_king.png");

const w_pawn_sprite = preload("res://ChessPieceSprites/white_pawn.png");
const w_rook_sprite = preload("res://ChessPieceSprites/white_rook.png");
const w_knight_sprite = preload("res://ChessPieceSprites/white_knight.png");
const w_bishop_sprite = preload("res://ChessPieceSprites/white_bishop.png");
const w_queen_sprite = preload("res://ChessPieceSprites/white_queen.png");
const w_king_sprite = preload("res://ChessPieceSprites/white_king.png");

const deselect = preload("res://sounds/sfx_pieceDeselectV1.ogg");
const piece_move = preload("res://sounds/sfx_pieceMove.ogg");

var bXOffset;
var bYOffset;
var sWidth;
var spriteScale;

var viewSize;

var pieces := [];
var highlight := [];
var selectedPiece;

class PieceSprite:
	var piece = Chessboard.Piece;
	var sprite;

var player : AudioStreamPlayer2D;
var check : AudioStreamPlayer2D;
var piece_kill : AudioStreamPlayer2D;
var select_1 : AudioStreamPlayer2D;
var select_2 : AudioStreamPlayer2D;
func _ready():
	player = get_node("/root/game/AudioStreamPlayer2D");
	check = get_node("/root/game/Check");
	piece_kill = get_node("/root/game/Kill");
	select_1 = get_node("/root/game/Select1");
	select_2 = get_node("/root/game/Select2");
	check.volume_db = Chessboard.volume;
	piece_kill.volume_db = Chessboard.volume;
	player.volume_db = Chessboard.volume;
	select_1.volume_db = Chessboard.volume;
	select_2.volume_db = Chessboard.volume;
	get_node("/root/game/Ambience").volume_db = 10 + Chessboard.volume;
	get_node("/root/game/Music").volume_db = Chessboard.volume - 2;
	viewSize = get_viewport().size;
	ScaleScreen();
	BuildBoard();

func BuildBoard():
	pieces.clear();
	for p in Chessboard._board:
		if p != null:
			var pieceSprite = PieceSprite.new();
			pieceSprite.piece = p;
			pieceSprite.sprite = Sprite2D.new();
			pieceSprite.sprite.position = Vector2(p.position.x*sWidth, p.position.y*sWidth);
			pieceSprite.sprite.scale = Vector2(spriteScale, spriteScale);
			pieceSprite.sprite.centered = false;
			pieces.append(pieceSprite);
			add_child(pieceSprite.sprite);
			if p.side == Chessboard.Piece.Side.WHITE:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = w_pawn_sprite;
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = w_rook_sprite;
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = w_knight_sprite;
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = w_bishop_sprite;
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = w_queen_sprite;
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = w_king_sprite;
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;
			else:
				match p.type:
					Chessboard.Piece.Type.PAWN:
						pieceSprite.sprite.texture = b_pawn_sprite;
					Chessboard.Piece.Type.ROOK:
						pieceSprite.sprite.texture = b_rook_sprite;
					Chessboard.Piece.Type.KNIGHT:
						pieceSprite.sprite.texture = b_knight_sprite;
					Chessboard.Piece.Type.BISHOP:
						pieceSprite.sprite.texture = b_bishop_sprite;
					Chessboard.Piece.Type.QUEEN:
						pieceSprite.sprite.texture = b_queen_sprite;
					Chessboard.Piece.Type.KING:
						pieceSprite.sprite.texture = b_king_sprite;
					_:
						printerr("Error drawing board: at least one chess piece does not have type");
						break;

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clickedValidPiece = false;
		var mousePos = event.position;
		if highlight.is_empty():
			for ps in pieces:
				if ps.sprite.get_rect().has_point(to_local(event.position)):
					pass
				var psS = ps.sprite;
				var psLH = psS.global_position.x;
				var psHH = psLH + sWidth;
				var psLV = psS.global_position.y;
				var psHV = psLV + sWidth;
				if mousePos.x < psHH and mousePos.y < psHV and mousePos.x > psLH and mousePos.y > psLV:
					clickedValidPiece = true;
					selectedPiece = ps;
					var to_load = [select_1, select_2];
					var select = to_load[randi_range(0, 1)];
					select.pitch_scale = randf_range(0.8, 1.5);
					select.play();
					var mvs = ps.piece.get_possible_moves();
					for move in mvs:
						if move.type != Chessboard.Move.Type.PROTECT:
							highlight.append(move);
			if not clickedValidPiece:
				selectedPiece = null;
				player.stream = deselect;
				player.pitch_scale = randf_range(0.8, 1.5);
				player.play();
				highlight.clear();
		else:
			for move in highlight:
				var mvLH = (move.position.x * sWidth) + bXOffset;
				var mvHH = mvLH + sWidth;
				var mvLV = (move.position.y * sWidth) + bYOffset;
				var mvHV = mvLV + sWidth;
				if mousePos.x < mvHH and mousePos.y < mvHV and mousePos.x > mvLH and mousePos.y > mvLV:
					if move.type != Chessboard.Move.Type.PROTECT:
						var gameState = move.execute.call();
						clickedValidPiece = true;
						if gameState.type == Chessboard.GameState.Type.PLAY:
							match move.type:
								Chessboard.Move.Type.MOVE:
									player.stream = piece_move;
									player.pitch_scale = randf_range(0.8, 1.5);
									player.play();
								Chessboard.Move.Type.CAPTURE:
									piece_kill.play();
								Chessboard.Move.Type.PROMOTION:
									player.stream = piece_move;
									player.pitch_scale = randf_range(0.8, 1.5);
									player.play();
						elif gameState.type == Chessboard.GameState.Type.CHECK:
							check.play();
						elif gameState.type == Chessboard.GameState.Type.CHECKMATE || gameState.type == Chessboard.GameState.Type.DRAW:
							check.play();
							var label = get_node("/root/game/Label");
							if gameState.type == Chessboard.GameState.Type.CHECKMATE:
								var side = "White";
								if gameState.in_check.side == Chessboard.Piece.Side.WHITE:
									side = "Black";
								label.text = side + " wins.";
							else:
								label.text = "Draw";
							await get_tree().create_timer(1.0).timeout;
							Chessboard.ClearBoard();
							get_tree().change_scene_to_file("res://menu.tscn");
				else:
					player.stream = deselect;
					player.pitch_scale = randf_range(0.8, 1.5);
					player.play();
			selectedPiece = null;
			highlight.clear();
		queue_redraw();

func _draw():
	if viewSize != get_viewport().size:
		viewSize = get_viewport().size
		ScaleScreen();
	for p in pieces:
		p.sprite.position = Vector2(p.piece.position.x*sWidth, p.piece.position.y*sWidth);
		if p.piece not in Chessboard._board:
			remove_child(p.sprite);
			pieces.erase(p);
	if selectedPiece != null:
		# draw_rect(selectedPiece.sprite.get_rect(), Color(Color.YELLOW, .5), true);
		var selectedHighlight = Rect2(selectedPiece.sprite.position.x, selectedPiece.sprite.position.y, sWidth, sWidth);
		draw_rect(selectedHighlight, Color(Color.BLUE, .5), true);
	for m in highlight:
		var posX = (m.position.x* sWidth);
		var posY = (m.position.y * sWidth);
		draw_rect(Rect2(posX, posY, sWidth, sWidth), Color(Color.WEB_PURPLE, .5), true);

func ScaleScreen():
	sWidth = min(viewSize.x / 8, viewSize.y / 8);
	bXOffset = (viewSize.x - sWidth * 8) / 2;
	bYOffset = (viewSize.y - sWidth * 8) / 2;
	spriteScale = sWidth / 1000.;
	position = Vector2(bXOffset, bYOffset);
	for p in pieces:
		p.sprite.position = Vector2(p.piece.position.x*sWidth, p.piece.position.y*sWidth);
		p.sprite.scale = Vector2(spriteScale, spriteScale);
