extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var relative_position = Vector2(0, 0)
var init_pos: Vector2

func user_func(time: float) -> float:
	return time

func _ready() -> void:
	init_pos = position

func _physics_process(delta: float) -> void:
	
	var x = relative_position.x
	var new_relative_position = Vector2(x, -user_func(x))
	var delta_relative_position = new_relative_position - relative_position
	var delta_abs = delta_relative_position.length()
	if delta_abs != 0:
		relative_position += delta_relative_position / delta_abs
	else:
		relative_position += delta_relative_position
	
	position = init_pos + relative_position
