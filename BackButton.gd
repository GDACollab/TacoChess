extends Button

func _pressed():
	Chessboard.ClearBoard();
	get_tree().change_scene_to_file("res://menu.tscn");
