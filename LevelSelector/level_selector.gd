extends Control

func _ready():
	pass

func _on_play_button_pressed_lvl1() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_lvl2() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_lvl3() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_lvl4() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")
	
func _on_play_button_pressed_lvl5() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")
	
func _on_play_button_pressed_lvl6() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_procedural_lvl() -> void:
	get_tree().change_scene_to_file("res://ProceduralLevel/proceduralLevel.tscn")
