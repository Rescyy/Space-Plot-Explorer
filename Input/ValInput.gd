class_name ValInput extends LineEdit

var on_text_submitted_callback: Callable
var on_text_changed_callback: Callable

func set_text_submitted_callback(callback: Callable):
	on_text_submitted_callback = callback

func set_text_changed_callback(callback: Callable):
	on_text_changed_callback = callback

func _ready() -> void:
	max_length = 10

func _process(delta: float) -> void:
	pass

func _on_text_changed(new_text: String):
	if len(new_text) > 0:
		var zeros = new_text.count("0")
		var minus = new_text.count("-")
		var repeatingZeros = zeros == len(new_text) and zeros > 1
		var startWithMinus = (minus == 1 and new_text[0] == '-') or minus == 0
		if new_text[-1] not in "1234567890.-" or new_text.count(".") > 1 or repeatingZeros or !startWithMinus:
			text = new_text.substr(0, len(new_text) - 1)
			caret_column = len(text)
	if on_text_changed_callback != null:
		on_text_changed_callback.call()

func _on_text_submitted(new_text: String):
	if on_text_submitted_callback != null:
		on_text_submitted_callback.call()

func get_value() -> float:
	return float(text)
