extends HSlider


# Called when the node enters the scene tree for the first time.
func _input(event):
	var div = self.value/100;
	var formula = -40 * pow(div, 3) + 90 * div - 40;
	Chessboard.volume = formula;
	var player : AudioStreamPlayer2D = get_node("/root/menu/AudioStreamPlayer2D");
	player.volume_db = formula;
	print(self.value);
