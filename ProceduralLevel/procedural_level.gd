extends Node2D

var rng = RandomNumberGenerator.new()
var points = []
var curve = Curve2D.new()

func rand_point(size: Vector2) -> Vector2:
	return Vector2(rng.randf_range(0, size.x), rng.randf_range(0, size.y))

func get_bezier_func(ps: Array) -> Callable:
	var _cubic_bezier = func(t: float):
		var q0 = ps[0].lerp(ps[1], t)
		var q1 = ps[1].lerp(ps[2], t)
		var q2 = ps[2].lerp(ps[3], t)

		var r0 = q0.lerp(q1, t)
		var r1 = q1.lerp(q2, t)

		var s = r0.lerp(r1, t)
		return s
	return _cubic_bezier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size: Vector2 = get_viewport_rect().size
	points = []
	const distinct_curves = 4
	for i in range(3*distinct_curves + 1):
		points.append(rand_point(size))
	var sortbyx = func(a: Vector2, b: Vector2):
		return a.x > b.x
	points.sort_custom(sortbyx)
	var bezier_func: Callable
	for i in range(0, 3*distinct_curves, 3):
		bezier_func = get_bezier_func(points.slice(i, i+4))
		for j in range(10):
			var t = j / 10.0
			curve.add_point(bezier_func.call(t))
	curve.add_point(bezier_func.call(1))
	print(curve.tessellate(5, 1))

func _draw():
	draw_polyline(curve.tessellate(5, 1), Color.BLACK, 3)
	for point in points:
		draw_circle(point, 5, Color.BLACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
