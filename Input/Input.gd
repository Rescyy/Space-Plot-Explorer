extends Node

var x = 0.0
var y = 0.0
var math_expr = ""
var time_passed = 0.0
var positions = []

func _process(delta: float) -> void:
	pass

func _on_text_submitted(p_expr: String) -> void:
	print("Submitted Expression: " + p_expr)
	math_expr = p_expr
	x = 0.0
	time_passed = 0.0
	positions.clear()
	var user_func_callable = Callable(self, "user_func")
	Global.set_user_func(user_func_callable)

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

func user_func(x_value: float) -> float:
	if math_expr == "":
		return 0.0
	return evaluate(math_expr, ["x"], [x_value])

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
