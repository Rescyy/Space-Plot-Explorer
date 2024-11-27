extends Node2D

@onready var levelBounds: StaticBody2D = $"."
@onready var spaceship: CharacterBody2D = $"StartPoint/Spaceship"
@onready var winArea: StaticBody2D = $"WinArea"

func _ready():
	pass

func _process(delta):
	var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		var collider = collision_body.get_collider()
		if not State.is_won() and not State.is_lost() and collider == levelBounds:
			print("Game lost")
			State.set_lost()
			get_tree().change_scene_to_file("res://LevelSelector/level_selector.tscn")
		elif not State.is_idle() and not State.is_won() and collider == winArea:
			print("Game won")
			State.set_won()
