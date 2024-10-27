extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

var relative_position = Vector2(0, 0)
var init_pos: Vector2
var end_x = 1000
var func_trajectory: Array[Vector2] = [Vector2.ZERO]
var trajectory_distances: Array[float] = [0]
var distance: float = 0
var is_moving = true

func user_func(x: float) -> float:
	var y = x
	return y

func _ready() -> void:
	var x: int = 0
	init_pos = position
	while x < end_x:
		x += 1
		func_trajectory.append(Vector2(x, user_func(x)))
		trajectory_distances.append(func_trajectory[x - 1].distance_to(func_trajectory[x - 2]) + trajectory_distances.back())

func _physics_process(delta: float) -> void:
	if is_moving:
		var ds = delta * SPEED
		distance += ds
		var i = trajectory_distances.bsearch(distance)
		var d1 = trajectory_distances[i-1]
		var d2 = trajectory_distances[i]
		var t = (distance - d1) / (d2 - d1)
		var x = i + t - 1
		var y = user_func(x)
		var new_position = init_pos + Vector2(x, -y)
		var delta_position = new_position - position
		rotation = -Vector2(-delta_position.y, -delta_position.x).angle()
		position = new_position
