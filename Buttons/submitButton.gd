class_name SubmitButton extends Button

@onready var spaceship: CharacterBody2D = $"../StartPoint/Spaceship"

var on_pressed_callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(self._on_pressed)

func set_on_pressed_callback(callback: Callable):
	self.on_pressed_callback = callback

func _on_pressed():
	if self.on_pressed_callback != null:
		self.on_pressed_callback.call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
