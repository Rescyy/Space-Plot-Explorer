extends Node

enum GameState {
	MAIN_MENU, 
	IDLE, 
	START,
	FLYING,
	LOST,
	WON,
}

var prev_game_state: GameState = GameState.MAIN_MENU
var game_state: GameState = GameState.MAIN_MENU
var game_state_changed: bool = false
var spaceship_path: PackedVector2Array
var spaceship_function: Callable

func set_spaceship_path(path: PackedVector2Array, function: Callable):
	if is_idle() or is_flying():
		self.spaceship_path = path
		self.spaceship_function = function
		game_state = GameState.START

func get_spaceship_path() -> PackedVector2Array:
	return self.spaceship_path

func call_spaceship_function(x) -> float:
	return spaceship_function.call(x)

func set_idle():
	game_state = GameState.IDLE

func set_lost():
	game_state = GameState.LOST

func set_won():
	game_state = GameState.WON

func set_start():
	game_state = GameState.START

func set_flying():
	game_state = GameState.FLYING

func is_idle() -> bool:
	return game_state == GameState.IDLE

func is_lost() -> bool:
	return game_state == GameState.LOST

func is_won() -> bool:
	return game_state == GameState.WON

func is_flying() -> bool:
	return game_state == GameState.FLYING

func is_start() -> bool:
	return game_state == GameState.START

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
