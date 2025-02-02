extends Node2D

@onready var levelBounds: StaticBody2D = $"."
@onready var spaceship: Spaceship = $"StartPoint/Spaceship"
@onready var winArea: StaticBody2D = $"WinArea"
@onready var aVal: ValInput = $"InputContainer/ValInput"
@onready var startPoint: Node2D = $"StartPoint"
@onready var submitButton: SubmitButton = $"SubmitButton"

var body: StaticBody2D = StaticBody2D.new()
var collision: CollisionPolygon2D = CollisionPolygon2D.new()
var path: PackedVector2Array

func make_collider_box(pos1: Vector2, pos2: Vector2):
	var minx = pos1.x - 1 
	var maxx = pos2.x + 1 
	var miny = minf(pos1.y, pos2.y) - 1
	var maxy = maxf(pos1.y, pos2.y) + 1
	var box = [Vector2(minx, miny), Vector2(maxx, miny), Vector2(maxx, maxy), Vector2(minx, maxy)]
	return PackedVector2Array(box)

func make_path_from_values():
	spaceship.reset()
	path.clear()
	body.collision_layer = 1
	body.collision_mask = 1
	if len(aVal.text) != 0:
		var a = float(aVal.text)
		var prevPos = Vector2.ZERO
		path.append(startPoint.position)
		var x = 1
		while x < 1000:
			var y = a * x
			var pos = Vector2(x, -y)
			var box = make_collider_box(prevPos, pos)
			prevPos = pos
			collision.polygon = box
			var collision_body = body.move_and_collide(Vector2.ZERO, true)
			path.append(pos + startPoint.position)
			if collision_body != null and collision_body.get_collider() != spaceship:
				break
			x += 1
	body.collision_layer = 0
	body.collision_mask = 0

func submit():
	if len(path) != 0 and len(aVal.text) != 0:
		var a = float(aVal.text)
		var spaceship_function = func (x):
			return a * x
		State.set_spaceship_path(path, spaceship_function)

func _ready():
	body.position = startPoint.position
	body.add_child(collision)
	add_child(body)
	aVal.set_text_changed_callback(make_path_from_values)
	aVal.set_text_submitted_callback(submit)
	submitButton.set_on_pressed_callback(submit)

func _process(delta):
	queue_redraw()
	if State.is_flying():
		var collision_body: KinematicCollision2D = spaceship.move_and_collide(Vector2.ZERO, true)
		if collision_body != null:
			var collider = collision_body.get_collider()
			if not State.is_won() and not State.is_lost() and collider == levelBounds:
				print("Game lost")
				State.set_lost()
			elif not State.is_idle() and not State.is_won() and collider == winArea:
				print("Game won")
				State.set_won()

func _draw():
	if path.size() > 1:
		draw_polyline(path, Color.GREEN, 1.5)
