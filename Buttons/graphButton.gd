extends Button

@onready var graph: Node2D = $"../StartPoint/Graph"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(self._on_pressed)

func _on_pressed() -> void:
	graph.visible = !graph.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
