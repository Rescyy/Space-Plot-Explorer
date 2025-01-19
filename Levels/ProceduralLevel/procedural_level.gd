extends Node2D

@onready var start_point: Node2D = $StartPoint
@onready var win_area: WinArea = $WinArea
@onready var spaceship: CharacterBody2D = $"StartPoint/Spaceship"
@onready var levelBounds: CollisionPolygon2D = $LevelBounds
@onready var funcInput: FuncInput = $"InputContainer/FuncInput"
@onready var submitButton: SubmitButton = $"SubmitButton"

var rng = RandomNumberGenerator.new()
var noiseObj = FastNoiseLite.new()
var points = []
var boundPolygon: PackedVector2Array = PackedVector2Array()
var before: PackedVector2Array = PackedVector2Array()
var backgroundColor: Color
var caveColor: Color
var borderColor: Color
var graphColor: Color

var body: StaticBody2D = StaticBody2D.new()
var collision: CollisionPolygon2D = CollisionPolygon2D.new()
var path: PackedVector2Array

func generate_level_colors():
	var hue: float = randf_range(0.0, 1.0)
	const saturation: float = 0.5
	const backgroundValue: float = 0.7
	const caveValue: float = 0.6
	const borderValue: float = 0.4
	const dev = 0.05
	backgroundColor = Color.from_hsv(
		fmod(hue + randf_range(-0.20, 0.20) + 1.0, 1.0),
		saturation + randf_range(-dev,dev),
		backgroundValue + randf_range(-dev,dev)
	)
	caveColor = Color.from_hsv(
		fmod(hue + randf_range(-0.20, 0.20) + 1.0, 1.0),
		saturation + randf_range(-dev,dev),
		caveValue + randf_range(-dev,dev)
	)
	borderColor = Color.from_hsv(
		fmod(hue + randf_range(-0.20, 0.20) + 1.0, 1.0),
		saturation + randf_range(-dev,dev),
		borderValue + randf_range(-dev,dev)
	)
	graphColor = caveColor.inverted()
	graphColor = Color.from_hsv(
		graphColor.h,
		1,
		1,
	)

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
	var perpendicular_dist = -sign(dydx)
	point.y += 50 
	point.x += 50 * perpendicular_dist 
	return point

func top_point(point: Vector2, t: float, bezier_derivative: Callable) -> Vector2:
	var derivative = bezier_derivative.call(t)
	var dydx = derivative.y / derivative.x
	var perpendicular_dist = sign(dydx)
	point.y += -50 
	point.x += 50 * perpendicular_dist 
	return point

func top_point_noise(point: Vector2):
	point.y += -abs(10 * noise(point.x / 100.0 + 420)) + rng.randf_range(-20, 0)
	point.x += 10 * noise(point.y) + rng.randf_range(-20, 20)
	return point

func bottom_point_noise(point: Vector2):
	point.y += abs(10 * noise(point.x / 100.0 + 420)) + rng.randf_range(0, 20)
	point.x += 10 * noise(point.y) + rng.randf_range(-20, 20)
	return point

func distance_to_line(point: Vector2, a: Vector2, b: Vector2):
	var distance_to_perpendicular = abs((b-a).cross(point-a))/a.distance_to(b)
	var dist_a = point.distance_to(a)
	var dist_b = point.distance_to(b)
	return max(min(dist_a, dist_b), distance_to_perpendicular)

func make_space(polygon: Array, from: Vector2)->Array:
	const min_distance: float = 70.0
	polygon.append(polygon[0])
	var new_points = []
	for i in range(len(polygon)-1):
		var point = polygon[i]
		var distance: float = from.distance_to(point)
		if distance < min_distance:
			point = from + from.direction_to(point) * min_distance
		new_points.append(point)
		var distance_from_line: float = distance_to_line(from, polygon[i], polygon[i+1])
		var middle_point = (polygon[i] + polygon[i+1]) / 2
		if distance_from_line < min_distance and from.distance_to(middle_point) < min_distance:
			point = middle_point
			point = from + from.direction_to(point) * min_distance
			new_points.append(point)
	polygon.pop_back()
	return new_points

func smooth_polygon(polygon: Array, smooth_factor) -> Array:
	var new_points = []
	polygon.append(polygon[0])
	polygon.append(polygon[1])
	for i in range(len(polygon) - 2):
		var p0 = polygon[i]
		var p1 = polygon[i+1]
		var p2 = polygon[i+2]
		new_points.append(p1.lerp((p0+p2)/2, smooth_factor))
	polygon.pop_back()
	polygon.pop_back()
	return new_points

func make_collider_box(pos1: Vector2, pos2: Vector2):
	var minx = pos1.x - 1 
	var maxx = pos2.x + 1 
	var miny = minf(pos1.y, pos2.y) - 1
	var maxy = maxf(pos1.y, pos2.y) + 1
	var box = [Vector2(minx, miny), Vector2(maxx, miny), Vector2(maxx, maxy), Vector2(minx, maxy)]
	return PackedVector2Array(box)

func make_path_from_values():
	body.position = start_point.position
	spaceship.reset()
	path.clear()
	body.collision_layer = 1
	body.collision_mask = 1
	if len(funcInput.text) != 0 and funcInput.function_valid:
		var function = funcInput.function
		var prevPos = Vector2.ZERO
		path.append(start_point.position)
		var x = 1
		while x < 1000:
			var y = function.call(x)
			var pos = Vector2(x, -y)
			var box = make_collider_box(prevPos, pos)
			prevPos = pos
			collision.polygon = box
			var collision_body = body.move_and_collide(Vector2.ZERO, true)
			path.append(pos + start_point.position)
			if collision_body != null and collision_body.get_collider() != spaceship:
				break
			x += 1
	body.collision_layer = 0
	body.collision_mask = 0

func submit():
	if len(path) != 0 and len(funcInput.text) != 0 and funcInput.function_valid:
		State.set_spaceship_path(path, funcInput.function)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body.add_child(collision)
	add_child(body)
	funcInput.set_text_changed_callback(make_path_from_values)
	funcInput.set_text_submitted_callback(submit)
	submitButton.set_on_pressed_callback(submit)
	
	const top = 50
	const bottom = 100
	const left = 75
	const right = 75
	var rect = pad_rect(get_viewport_rect(), top, bottom, left, right)
	
	generate_level_colors()
	
	const distinct_curves = 3
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
	var topPoints = []
	var bottomPoints = []
	firstPoint.x -= 40
	lastPoint.x += 40

	const iter = 10
	for i in range(len(bezier_funcs)):
		for j in range(10):
			var t = j / float(iter)
			var bezier_func = bezier_funcs[i]
			var bezier_derivative = bezier_derivatives[i]
			var point = bezier_func.call(t)
			var topPoint = top_point(point, t, bezier_derivative)
			var bottomPoint = bottom_point(point, t, bezier_derivative)

			if len(topPoints) == 0 or topPoint.x >= topPoints[-1].x:
				topPoints.append(topPoint)
			elif len(topPoints) > 1:
				topPoints.pop_back()
			
			if len(bottomPoints) == 0 or bottomPoint.x >= bottomPoints[-1].x:
				bottomPoints.append(bottomPoint)
			elif len(bottomPoints) > 1:
				bottomPoints.pop_back()

	#topPoints.sort_custom(sortbyx)
	#bottomPoints.sort_custom(sortbyx)
	topPoints = topPoints.map(top_point_noise)
	bottomPoints = bottomPoints.map(bottom_point_noise)

	boundPolygon.append(firstPoint)
	boundPolygon.append_array(topPoints)
	boundPolygon.append(lastPoint)
	bottomPoints.reverse()
	boundPolygon.append_array(bottomPoints)
	
	start_point.position = points[0] + Vector2(10,0)
	win_area.position = (topPoints[-1] + bottomPoints[0] + lastPoint) / 3

	before = boundPolygon.duplicate()
	boundPolygon = smooth_polygon(boundPolygon, 0.2)
	boundPolygon = make_space(boundPolygon, start_point.position)
	boundPolygon = make_space(boundPolygon, win_area.position)

	$LevelBounds.polygon = PackedVector2Array(boundPolygon)
	boundPolygon.append(boundPolygon[0])

func _draw():
	draw_rect(get_viewport_rect(), backgroundColor)
	draw_colored_polygon(boundPolygon, caveColor)
	draw_polyline(boundPolygon, borderColor, 4)
	if len(path) > 1:
		draw_polyline(path, graphColor, 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
	if collision_body != null:
		var collider = collision_body.get_collider()
		if not State.is_won() and not State.is_lost() and collider == $".":
			print("Game lost")
			State.set_lost()
		if not State.is_idle() and not State.is_won() and collider == win_area:
			print("Game won")
			State.set_won()
