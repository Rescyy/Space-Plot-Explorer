extends Control

func _ready():
	pass

func _on_settings_button_pressed():
	print("Settings button pressed")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed() -> void:
	State.set_idle()
	get_tree().change_scene_to_file("res://LevelSelector/level_selector.tscn")
