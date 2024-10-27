extends Node2D
@onready var level_body: StaticBody2D = $StaticBody2D
@onready var character_body: CharacterBody2D = $CharacterBody2D


func _ready():
	level_body.collision_mask = 1
	character_body.collision_layer = 1
	

func _process(delta):

	if _is_game_lost():
		print("Game lost")
	
func _is_game_lost():
	var collision_body: KinematicCollision2D = character_body.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		return true
	return false
