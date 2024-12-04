class_name Spaceship extends CharacterBody2D

@onready var winArea: Node2D = $"../../WinArea"
@onready var startPoint: Node2D = $".."

const SPEED = 300.0

var init_pos: Vector2
var end_x = 1200
var path: Array[Vector2]
var arc_length: Array[float]
var distance: float = 0
var trajectory_calculated = false
var prev_velocity: Vector2 = Vector2.ZERO

var win_vars = false
var win_position = null
var win_time = null
var win_rotation = null


var callable_dict = {
	State.GameState.FLYING: Callable(self, "start")
}

func _init(init_pos: Vector2=Vector2.ZERO):
	self.init_pos = init_pos

func _ready() -> void:
	pass

func compute_trajectory():
	path = [Vector2.ZERO]
	arc_length = [0]
	self.prev_velocity = Vector2.ZERO
	var x: int = 0
	while x < end_x:
		x += 1
		path.append(Vector2(x, State.user_func(x)))
	for i in range(1, len(path)):
		arc_length.append(path[i].distance_to(path[i - 1]) + arc_length.back())
	
	trajectory_calculated = true

func rotation_from_vec(vec: Vector2) -> float:
	return -Vector2(-vec.y, -vec.x).angle()

func calculate_rotation_from_vec(next_position: Vector2, delta: float) -> float:
	var _velocity = next_position - position
	_velocity = _velocity.normalized() * delta
	var delta_velocity = 1.1 * _velocity - prev_velocity
	prev_velocity = _velocity
	return rotation_from_vec(delta_velocity)

func calculate_rotation_from_pos(next_position: Vector2, delta: float) -> float:
	prev_velocity = next_position - position
	return rotation_from_vec(prev_velocity)

func ease_out(x: float) -> float:
	return - (x-1)*(x-1) + 1

func _physics_process(delta: float) -> void:
	if State.is_start():
		reset()
		compute_trajectory()
		State.set_flying()
	elif State.is_flying():
		var ds = delta * SPEED
		distance += ds
		var i = arc_length.bsearch(distance)
		if i > end_x:
			State.set_lost()
			return
		var d1 = arc_length[i-1]
		var d2 = arc_length[i]
		var t = (distance - d1) / (d2 - d1)
		var x = i + t - 1
		var y = State.user_func(x)
		var new_position = self.init_pos + Vector2(x, -y)
		rotation = calculate_rotation_from_vec(new_position, delta)
		position = new_position
	elif State.is_lost():
		reset()
	elif State.is_won():
		if not win_vars:
			win_vars = true
			win_position = position
			win_time = delta
			win_rotation = rotation
			print(rotation)
		if win_time >= 1.0:
			State.set_idle()
		var scale_factor = 1.0 - win_time
		scale = Vector2(scale_factor, scale_factor*scale_factor)
		var new_position = win_position.lerp(
			winArea.position - startPoint.position, 
			ease_out(win_time)
		)
		rotation = lerp(win_rotation, 0.0, win_time)
		position = new_position
		win_time += delta

func reset():
	State.set_idle()
	distance = 0
	trajectory_calculated = false
	position = self.init_pos
	rotation = 0
	scale = Vector2.ONE
	prev_velocity = Vector2.ZERO
	win_vars = false
