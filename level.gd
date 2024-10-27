extends Node2D
@onready var level: StaticBody2D = $"."
@onready var spaceship: CharacterBody2D = $Spaceship


func _ready():
	level.collision_mask = 1
	spaceship.collision_layer = 1

func _process(delta):
	if _is_game_lost():
		print("Game lost")

func _is_game_lost():
	var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		return true
	return false
