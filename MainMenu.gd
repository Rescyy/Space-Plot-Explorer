extends Control

func _ready():
	pass

func _on_settings_button_pressed():
	# Code to open settings (either a new scene or a popup)
	print("Settings button pressed")

func _on_quit_button_pressed():
	# Code to quit the game
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")
