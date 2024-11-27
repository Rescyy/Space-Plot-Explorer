extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _draw():
	for i in range(0, 10):
		var weight = i / 10.0
		draw_circle(
			Vector2.ZERO, 
			lerp(45, 10, weight), 
			Color.DIM_GRAY.lerp(Color.BLACK, weight),
			false,
			4.5
		)
	draw_circle(Vector2.ZERO, 47, Color.BLACK, false, 3)
	draw_circle(Vector2.ZERO, 10, Color.BLACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
