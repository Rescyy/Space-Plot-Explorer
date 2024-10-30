extends Node2D

@onready var spaceship: CharacterBody2D = $"../StartPoint/Spaceship"

func _ready():
	pass

func _process(delta):
	if _is_game_win() and not State.is_win():
		print("Game won")
		State.set_win()

func _is_game_win():
	var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		print(collision_body.get_collider())
		return true
	return false
