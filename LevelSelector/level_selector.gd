extends Control

func _ready():
	pass

func _on_play_button_pressed_lvl1() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_lvl2() -> void:
	get_tree().change_scene_to_file("res://Levels/Level2/level2.tscn")

func _on_play_button_pressed_lvl3() -> void:
	pass
	#get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_lvl4() -> void:
	pass
	#get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")
	
func _on_play_button_pressed_lvl5() -> void:
	pass
	#get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")
	
func _on_play_button_pressed_lvl6() -> void:
	pass
	#get_tree().change_scene_to_file("res://Levels/Level1/level.tscn")

func _on_play_button_pressed_procedural_lvl() -> void:
	get_tree().change_scene_to_file("res://Levels/ProceduralLevel/proceduralLevel.tscn")
