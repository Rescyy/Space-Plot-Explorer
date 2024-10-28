extends Node

var user_func: Callable
var has_user_func: bool = false

func set_user_func(user_func: Callable):
	self.user_func = user_func
	has_user_func = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
