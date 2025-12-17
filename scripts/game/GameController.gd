## GameController.gd
## Manages the game state machine, turn logic, and coordinates between UI and game logic.
class_name GameController
extends RefCounted

# Game states
enum GameState { MENU, PLAYING, GAME_OVER }

# Signals for UI updates
signal state_changed(new_state: GameState)
signal turn_changed(current_player: int)
signal move_made(cell_index: int, player: int)
signal game_over(result: String, winner: int)  # result: "win", "draw"
signal hint_available(cell_index: int)

# Current game state
var current_state: GameState = GameState.MENU

# Board instance
var board: Board

# AI instance
var ai: TicTacToeAI

# Player configuration
var human_player: int = Board.PLAYER_X
var ai_player: int = Board.PLAYER_O
var current_turn: int = Board.PLAYER_X  # X always starts

# Game mode
var is_pve: bool = true  # Player vs Engine

# Difficulty setting
var difficulty: TicTacToeAI.Difficulty = TicTacToeAI.Difficulty.MEDIUM

# Flags
var _ai_thinking: bool = false
var _rewarded_used_this_match: bool = false
var _hint_shown_this_turn: bool = false

# Saved state for undo functionality
var _saved_board_state: Array[int] = []
var _saved_move_history: Array[int] = []
var _saved_current_turn: int = Board.PLAYER_X


func _init() -> void:
	board = Board.new()
	ai = TicTacToeAI.new(ai_player, difficulty)


## Starts a new game with the specified settings
func start_game(player_symbol: int = Board.PLAYER_X, diff: TicTacToeAI.Difficulty = TicTacToeAI.Difficulty.MEDIUM, pve: bool = true) -> void:
	# Reset board
	board.reset()

	# Configure players
	human_player = player_symbol
	ai_player = Board.get_opponent(human_player)
	difficulty = diff
	is_pve = pve

	# Configure AI
	ai.set_player(ai_player)
	ai.set_difficulty(difficulty)

	# X always starts
	current_turn = Board.PLAYER_X

	# Reset flags
	_ai_thinking = false
	_rewarded_used_this_match = false
	_hint_shown_this_turn = false

	# Save initial state
	_save_state()

	# Update state
	current_state = GameState.PLAYING
	state_changed.emit(current_state)
	turn_changed.emit(current_turn)


## Attempts to make a move at the specified cell
## Returns true if the move was successful
func try_move(cell_index: int) -> bool:
	if current_state != GameState.PLAYING:
		return false

	if _ai_thinking:
		return false

	# In PvE, only allow moves on human's turn
	if is_pve and current_turn != human_player:
		return false

	if not board.is_legal_move(cell_index):
		return false

	# Make the move
	_make_move(cell_index, current_turn)
	return true


## Internal: makes a move and handles game flow
func _make_move(cell_index: int, player: int) -> void:
	# Save state before move
	_save_state()

	board.apply_move(cell_index, player)
	move_made.emit(cell_index, player)
	_hint_shown_this_turn = false

	# Check for game over
	if board.is_game_over():
		_handle_game_over()
		return

	# Switch turns
	current_turn = Board.get_opponent(current_turn)
	turn_changed.emit(current_turn)


## Handles game over state
func _handle_game_over() -> void:
	current_state = GameState.GAME_OVER
	state_changed.emit(current_state)

	var winner := board.get_winner()
	if winner != Board.EMPTY:
		game_over.emit("win", winner)
	else:
		game_over.emit("draw", Board.EMPTY)


## Called by the game scene to trigger AI move (after a delay)
func request_ai_move() -> void:
	if current_state != GameState.PLAYING:
		return
	if not is_pve:
		return
	if current_turn != ai_player:
		return
	if _ai_thinking:
		return

	_ai_thinking = true
	var best_move := ai.get_best_move(board)
	_ai_thinking = false

	if best_move != -1:
		_make_move(best_move, ai_player)


## Checks if it's currently the AI's turn
func is_ai_turn() -> bool:
	return is_pve and current_turn == ai_player and current_state == GameState.PLAYING


## Returns to menu state
func return_to_menu() -> void:
	current_state = GameState.MENU
	state_changed.emit(current_state)


## Restarts the current game with same settings
func restart_game() -> void:
	start_game(human_player, difficulty, is_pve)


## Gets the current board state
func get_board() -> Board:
	return board


## Gets the winner (if any)
func get_winner() -> int:
	return board.get_winner()


## Gets the winning line indices
func get_winning_line() -> Array[int]:
	return board.get_winning_line()


## Checks if rewarded action can be used
func can_use_rewarded() -> bool:
	return not _rewarded_used_this_match


## Marks rewarded action as used
func use_rewarded() -> void:
	_rewarded_used_this_match = true


## Requests a hint for the current player
## Returns the recommended cell index, or -1 if not available
func request_hint() -> int:
	if current_state != GameState.PLAYING:
		return -1
	if _hint_shown_this_turn:
		return -1

	var hint_move := ai.get_hint_for_player(board, human_player)
	if hint_move != -1:
		_hint_shown_this_turn = true
		hint_available.emit(hint_move)
	return hint_move


## Performs undo (restores previous state)
## Returns true if successful
func perform_undo() -> bool:
	if _saved_board_state.is_empty():
		return false

	# Restore board state
	board.cells = _saved_board_state.duplicate()
	board.move_history = _saved_move_history.duplicate()
	current_turn = _saved_current_turn

	# If was game over, return to playing
	if current_state == GameState.GAME_OVER:
		current_state = GameState.PLAYING
		state_changed.emit(current_state)

	turn_changed.emit(current_turn)
	return true


## Saves current state for undo
func _save_state() -> void:
	_saved_board_state = board.cells.duplicate()
	_saved_move_history = board.move_history.duplicate()
	_saved_current_turn = current_turn


## Returns the game result as a dictionary for stats
func get_game_result() -> Dictionary:
	var winner := board.get_winner()
	var result := {
		"is_draw": board.is_draw(),
		"winner": winner,
		"human_won": winner == human_player,
		"ai_won": winner == ai_player,
		"difficulty": TicTacToeAI.difficulty_to_string(difficulty)
	}
	return result


## Gets current game information
func get_game_info() -> Dictionary:
	return {
		"state": current_state,
		"current_turn": current_turn,
		"human_player": human_player,
		"ai_player": ai_player,
		"difficulty": difficulty,
		"is_pve": is_pve,
		"move_count": board.get_move_count()
	}
