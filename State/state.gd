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
var _user_func: Callable
var has_user_func: bool = false
var y0 = null

func set_user_func(_user_func: Callable):
	if is_idle() or is_flying():
		self._user_func = _user_func
		has_user_func = true
		self.y0 = _user_func.call(0)
		game_state = GameState.START

func user_func(x):
	if has_user_func:
		return self._user_func.call(x) - self.y0
	return null

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
	game_state_changed = game_state != prev_game_state
	if game_state_changed:
		print("Game State Changed")
	prev_game_state = game_state
