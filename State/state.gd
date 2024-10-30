extends Node

enum GameState {
	MAIN_MENU, 
	IDLE, 
	FLYING,
	LOST,
	WON,
}

var prev_game_state: GameState = GameState.MAIN_MENU
var game_state: GameState = GameState.MAIN_MENU
var game_state_changed: bool = false
var user_func: Callable
var has_user_func: bool = false

func set_user_func(user_func: Callable):
	if game_state == GameState.IDLE:
		self.user_func = user_func
		has_user_func = true
		game_state = GameState.FLYING

func set_idle():
	game_state = GameState.IDLE

func set_lost():
	game_state = GameState.LOST

func set_won():
	game_state = GameState.WON

func is_idle() -> bool:
	return game_state == GameState.IDLE

func is_lost() -> bool:
	return game_state == GameState.LOST

func is_won() -> bool:
	return game_state == GameState.WON

func is_flying() -> bool:
	return game_state == GameState.FLYING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	game_state_changed = game_state != prev_game_state
	if game_state_changed:
		print("Game State Changed")
	prev_game_state = game_state
