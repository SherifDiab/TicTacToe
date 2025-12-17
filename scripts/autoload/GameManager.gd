## GameManager.gd
## Global game manager autoload.
## Handles game state, scene transitions, and global game settings.
extends Node

# Signals
signal difficulty_changed(difficulty: TicTacToeAI.Difficulty)
signal player_symbol_changed(symbol: int)

# Current game controller
var game_controller: GameController

# Settings
var current_difficulty: TicTacToeAI.Difficulty = TicTacToeAI.Difficulty.MEDIUM
var player_symbol: int = Board.PLAYER_X
var is_pve_mode: bool = true

# Scene paths
const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GAME_SCENE := "res://scenes/Game.tscn"


func _ready() -> void:
	# Initialize game controller
	game_controller = GameController.new()
	print("GameManager: Initialized")


## Sets the game difficulty
func set_difficulty(difficulty: TicTacToeAI.Difficulty) -> void:
	current_difficulty = difficulty
	difficulty_changed.emit(difficulty)
	print("GameManager: Difficulty set to ", TicTacToeAI.difficulty_to_string(difficulty))


## Sets the player symbol (X or O)
func set_player_symbol(symbol: int) -> void:
	player_symbol = symbol
	player_symbol_changed.emit(symbol)
	print("GameManager: Player symbol set to ", Board.player_to_string(symbol))


## Gets the difficulty as string
func get_difficulty_string() -> String:
	return TicTacToeAI.difficulty_to_string(current_difficulty)


## Gets the player symbol as string
func get_player_symbol_string() -> String:
	return Board.player_to_string(player_symbol)


## Starts a new game with current settings
func start_new_game() -> void:
	game_controller.start_game(player_symbol, current_difficulty, is_pve_mode)


## Navigates to the game scene
func go_to_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


## Navigates to the main menu
func go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


## Quits the game
func quit_game() -> void:
	get_tree().quit()


## Gets the current game controller
func get_game_controller() -> GameController:
	return game_controller


## Records the game result to stats
func record_game_result() -> void:
	var result := game_controller.get_game_result()
	StatsStore.record_game(result)
