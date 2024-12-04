extends Node2D

var rng = RandomNumberGenerator.new()
var noiseObj = FastNoiseLite.new()
var points = []
var bezierPoints = []
var topPoints = []
var bottomPoints = []
@onready var start_point: Node2D = $StartPoint
@onready var win_area: WinArea = $WinArea
#@onready var levelBounds: StaticBody2D = $"."
@onready var spaceship: CharacterBody2D = $"StartPoint/Spaceship"

func noise(x: float) -> float:
	return noiseObj.get_noise_1d(x)

func rand_point(rect: Rect2) -> Vector2:
	var pos = rect.position
	var size = rect.size
	var left = pos.x
	var right = pos.x + size.x
	var top = pos.y
	var bottom = pos.y + size.y
	return Vector2(rng.randf_range(left, right), rng.randf_range(top, bottom))

func pad_rect(rect: Rect2, top: float=0.0, bottom: float=0.0, left: float=0.0, right: float=0.0) -> Rect2:
	var x = rect.position.x
	var y = rect.position.y
	var width = rect.size.x
	var height = rect.size.y
	return Rect2(x+left, y+top, width-left-right, height-top-bottom)

func get_bezier_func(ps: Array) -> Callable:
	var _cubic_bezier = func(t: float) -> Vector2:
		var _t = 1-t
		return ps[0]*(_t**3) + 3*t*_t*(ps[1]*_t + ps[2]*t) + ps[3]*(t**3)
		
	return _cubic_bezier

func get_bezier_derivative(ps: Array) -> Callable:
	var _cubic_bezier_derivative = func(t: float) -> Vector2:
		var _t = 1-t
		return 3*_t*_t*(ps[1]-ps[0]) + 6*_t*t*(ps[2]-ps[1]) + 3*t*t*(ps[3]-ps[2])
	
	return _cubic_bezier_derivative

func bottom_point(point: Vector2, t: float, bezier_derivative: Callable) -> Vector2:
	var derivative = bezier_derivative.call(t)
	var dydx = derivative.y / derivative.x
	var perpendicular_dist = -sign(dydx) / sqrt(1 + 1/(dydx*dydx))
	point.y += 50 
	point.x += 50 * perpendicular_dist 
	return point

func top_point(point: Vector2, t: float, bezier_derivative: Callable) -> Vector2:
	var derivative = bezier_derivative.call(t)
	var dydx = derivative.y / derivative.x
	var perpendicular_dist = sign(dydx) / sqrt(1 + 1/(dydx*dydx))
	point.y += -50 
	point.x += 50 * perpendicular_dist 
	return point

func noise_point(point: Vector2):
	point.y += 10 * noise(point.x / 100.0 + 420) + rng.randf_range(-20, 20)
	point.x += 10 * noise(point.y) + rng.randf_range(-20, 20)
	return point

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	const top = 50
	const bottom = 100
	const left = 75
	const right = 75
	var rect = pad_rect(get_viewport_rect(), top, bottom, left, right)
	
	const distinct_curves = 4
	points.append(
		Vector2(
			left, 
			randf_range(top, rect.position.y + rect.size.y)
		)
	)
	
	for i in range(3*distinct_curves - 1):
		points.append(rand_point(rect))

	points.append(
		Vector2(
			rect.position.x + rect.size.x, 
			randf_range(top, rect.position.y + rect.size.y)
		)
	)
	
	var sortbyx = func(a: Vector2, b: Vector2):
		return a.x < b.x
	points.sort_custom(sortbyx)
	var bezier_funcs: Array
	var bezier_derivatives: Array

	for i in range(0, 3*distinct_curves, 3):
		var slice = points.slice(i, i+4)
		var bezier_func = get_bezier_func(slice)
		var bezier_derivative = get_bezier_derivative(slice)
		bezier_funcs.append(bezier_func)
		bezier_derivatives.append(bezier_derivative)

	var firstPoint = points[0]
	var lastPoint = points[-1]
	firstPoint.x -= 40
	lastPoint.x += 40

	for i in range(len(bezier_funcs)):
		for j in range(10):
			var t = j / 10.0
			var bezier_func = bezier_funcs[i]
			var bezier_derivative = bezier_derivatives[i]
			var point = bezier_func.call(t)
			bezierPoints.append(point)
			var topPoint = top_point(point, t, bezier_derivative)
			var bottomPoint = bottom_point(point, t, bezier_derivative)

			if len(topPoints) == 0 or topPoint.x >= topPoints[-1].x:
				topPoints.append(topPoint)
			elif len(topPoints) > 1:
				#pass
				topPoints.pop_back()
			
			if len(bottomPoints) == 0 or bottomPoint.x >= bottomPoints[-1].x:
				bottomPoints.append(bottomPoint)
			elif len(bottomPoints) > 1:
				#pass
				bottomPoints.pop_back()

	topPoints = topPoints.map(noise_point)
	bottomPoints = bottomPoints.map(noise_point)

	#topPoints.sort_custom(sortbyx)
	#bottomPoints.sort_custom(sortbyx)

	topPoints.insert(0, firstPoint)
	bottomPoints.insert(0, firstPoint)
	topPoints.append(lastPoint)
	bottomPoints.append(lastPoint)
	bezierPoints.append(bezier_funcs[-1].call(1))
	
	start_point.position = points[0] + Vector2(10,0)
	win_area.position = points[-1] - Vector2(-10,0)

func _draw():
	draw_polyline(topPoints, Color.RED, 3)
	draw_polyline(bottomPoints, Color.BLUE, 3)
	draw_polyline(bezierPoints, Color.BLACK, 3)
	for point in points:
		draw_circle(point, 5, Color.GREEN)
	#draw_circle(startPointPos, 25.0, Color.WHITE)
	#draw_circle(winAreaPos, 48.0, Color.BLACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		var collider = collision_body.get_collider()
		#if not State.is_won() and not State.is_lost() and collider == levelBounds:
			#print("Game lost")
			#State.set_lost()
			#get_tree().change_scene_to_file("res://LevelSelector/level_selector.tscn")
		if not State.is_idle() and not State.is_won() and collider == win_area:
			print("Game won")
			State.set_won()
