extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var relative_position = Vector2(0, 0)
var init_pos: Vector2
var end_x = 1000
var func_trajectory: Array[Vector2] = [Vector2.ZERO]
var trajectory_distances: Array[float] = [0]
var distance: float = 0
var _user_func: Callable
var is_moving = false

func _ready() -> void:
	self.init_pos = position

func compute_trajectory():
	var x: int = 0
	while x < end_x:
		x += 1
		func_trajectory.append(Vector2(x, _user_func.call(x)))
		trajectory_distances.append(func_trajectory[x - 1].distance_to(func_trajectory[x - 2]) + trajectory_distances.back())

func start(user_func: Callable):
	_user_func = user_func
	compute_trajectory()
	is_moving = true

func _physics_process(delta: float) -> void:
	if Global.has_user_func and not is_moving:
		start(Global.user_func)
	if is_moving:
		var ds = delta * SPEED
		distance += ds
		var i = trajectory_distances.bsearch(distance)
		var d1 = trajectory_distances[i-1]
		var d2 = trajectory_distances[i]
		var t = (distance - d1) / (d2 - d1)
		var x = i + t - 1
		var y = _user_func.call(x)
		var new_position = self.init_pos + Vector2(x, -y)
		var delta_position = new_position - position
		rotation = -Vector2(-delta_position.y, -delta_position.x).angle()
		position = new_position
