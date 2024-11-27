extends Button

@onready var spaceship: CharacterBody2D = $"../StartPoint/Spaceship"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(spaceship)
	pressed.connect(self._on_pressed)

func _on_pressed():
	spaceship.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
