extends Node

var math_expr = ""

func _process(delta: float) -> void:
	pass

func _on_text_submitted(p_expr: String) -> void:
	print("Submitted Expression: " + p_expr)
	math_expr = p_expr
	var user_func_callable = Callable(self, "user_func")
	State.set_user_func(user_func_callable)

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
