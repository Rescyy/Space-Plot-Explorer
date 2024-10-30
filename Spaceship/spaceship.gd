extends CharacterBody2D

const SPEED = 200.0

var init_pos: Vector2
var end_x = 1000
var func_trajectory: Array[Vector2]
var trajectory_distances: Array[float]
var distance: float = 0
var trajectory_calculated = false

var callable_dict = {
	State.GameState.FLYING: Callable(self, "start")
}

func _ready() -> void:
	self.init_pos = position

func compute_trajectory():
	func_trajectory = [Vector2.ZERO]
	trajectory_distances = [0]
	var x: int = 0
	while x < end_x:
		x += 1
		func_trajectory.append(Vector2(x, State.user_func.call(x)))
		trajectory_distances.append(func_trajectory[x - 1].distance_to(func_trajectory[x - 2]) + trajectory_distances.back())
	trajectory_calculated = true

func _physics_process(delta: float) -> void:
	if State.is_flying():
		if not trajectory_calculated:
			compute_trajectory()
		var ds = delta * SPEED
		distance += ds
		var i = trajectory_distances.bsearch(distance)
		var d1 = trajectory_distances[i-1]
		var d2 = trajectory_distances[i]
		var t = (distance - d1) / (d2 - d1)
		var x = i + t - 1
		var y = State.user_func.call(x)
		var new_position = self.init_pos + Vector2(x, -y)
		var delta_position = new_position - position
		rotation = -Vector2(-delta_position.y, -delta_position.x).angle()
		position = new_position
	if State.is_lost():
		distance = 0
		trajectory_calculated = false
		position = self.init_pos
		State.set_idle()
	if State.is_won():
		pass
