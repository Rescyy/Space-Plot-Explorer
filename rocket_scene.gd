extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var x = 0.0
var y = 0.0
var math_expr = ""
var time_passed = 0.0
var positions = []
var is_moving = false

var relative_position = Vector2(0, 0)
var init_pos: Vector2

func evaluate(command: String, variable_names: Array, variable_values: Array) -> float:
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return 0

	var result = expression.execute(variable_values, self)
	if expression.has_execute_failed():
		push_error("Execution failed: " + expression.get_error_text())
		return 0

	return result
		
func _on_func_submit(expr: String) -> void:
	math_expr = expr
	x = 0.0
	time_passed = 0.0
	positions.clear()
	is_moving = true
	

func user_func(x_value: float) -> float:
	if math_expr == "":
		return 0.0
	return evaluate(math_expr, ["x"], [x_value])

func _ready() -> void:
	init_pos = position

func calculate_velocity():
	var velocities = []
	for i in range(1, positions.size()):
		var prev = positions[i - 1]
		var current = positions[i]
		var delta_time = current["time"] - prev["time"]
		if delta_time > 0:
			var delta_position = current["position"] - prev["position"]
			var velocity = delta_position / delta_time
			velocities.append(velocity)
	return velocities

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	time_passed += delta
	x += delta * SPEED  
	var y = -user_func(x)  

	relative_position = Vector2(x, y)
	position = init_pos + relative_position

	positions.append({ "time": time_passed, "position": position })
