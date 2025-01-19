extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(self._on_pressed)

func _on_pressed():
	get_tree().change_scene_to_file("res://LevelSelector/level_selector.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
