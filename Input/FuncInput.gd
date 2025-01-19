class_name FuncInput extends LineEdit

var on_text_submitted_callback: Callable
var on_text_changed_callback: Callable
var function: Callable
var function_valid: bool

func set_text_submitted_callback(callback: Callable):
	on_text_submitted_callback = callback

func set_text_changed_callback(callback: Callable):
	on_text_changed_callback = callback

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_text_changed(expr: String) -> void:
	if len(expr) == 0:
		function_valid = false
	else:
		var expression = Expression.new()
		var error = expression.parse(expr, ['x'])
		if error != OK:
			function_valid = false
		else:
			function_valid = true
			var y0 = expression.execute([0], self)
			if y0 == null:
				function_valid = false
			else:
				function = func(x):
					return expression.execute([x], self) - y0
	if !on_text_changed_callback.is_null():
		on_text_changed_callback.call()

func _on_text_submitted(p_expr: String) -> void:
	if !on_text_submitted_callback.is_null():
		on_text_submitted_callback.call()
