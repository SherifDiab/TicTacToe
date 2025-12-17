## Board.gd
## Manages the Tic-Tac-Toe board state, legal moves, and win detection.
## Pure game logic with no UI dependencies.
class_name Board
extends RefCounted

# Constants for cell states
const EMPTY: int = 0
const PLAYER_X: int = 1
const PLAYER_O: int = 2

# Board state: 9 cells in a flat array (indices 0-8)
# Layout:
# 0 | 1 | 2
# ---------
# 3 | 4 | 5
# ---------
# 6 | 7 | 8
var cells: Array[int] = []

# All possible winning lines (indices)
const WIN_LINES: Array = [
	[0, 1, 2],  # Top row
	[3, 4, 5],  # Middle row
	[6, 7, 8],  # Bottom row
	[0, 3, 6],  # Left column
	[1, 4, 7],  # Middle column
	[2, 5, 8],  # Right column
	[0, 4, 8],  # Diagonal top-left to bottom-right
	[2, 4, 6],  # Diagonal top-right to bottom-left
]

# Move history for undo functionality
var move_history: Array[int] = []


func _init() -> void:
	reset()


## Resets the board to initial empty state
func reset() -> void:
	cells.clear()
	cells.resize(9)
	cells.fill(EMPTY)
	move_history.clear()


## Returns a deep copy of the current board
func duplicate_board() -> Board:
	var new_board := Board.new()
	new_board.cells = cells.duplicate()
	new_board.move_history = move_history.duplicate()
	return new_board


## Returns all empty cell indices (legal moves)
func get_legal_moves() -> Array[int]:
	var moves: Array[int] = []
	for i in range(9):
		if cells[i] == EMPTY:
			moves.append(i)
	return moves


## Checks if a move is legal
func is_legal_move(cell_index: int) -> bool:
	return cell_index >= 0 and cell_index < 9 and cells[cell_index] == EMPTY


## Applies a move to the board
## Returns true if successful, false if invalid
func apply_move(cell_index: int, player: int) -> bool:
	if not is_legal_move(cell_index):
		return false
	if player != PLAYER_X and player != PLAYER_O:
		return false

	cells[cell_index] = player
	move_history.append(cell_index)
	return true


## Undoes the last move
## Returns the cell index that was undone, or -1 if no moves to undo
func undo_move() -> int:
	if move_history.is_empty():
		return -1

	var last_move: int = move_history.pop_back()
	cells[last_move] = EMPTY
	return last_move


## Gets the cell value at the given index
func get_cell(cell_index: int) -> int:
	if cell_index < 0 or cell_index >= 9:
		return EMPTY
	return cells[cell_index]


## Returns the winning player (PLAYER_X, PLAYER_O) or EMPTY if no winner
func get_winner() -> int:
	for line in WIN_LINES:
		var a: int = cells[line[0]]
		var b: int = cells[line[1]]
		var c: int = cells[line[2]]
		if a != EMPTY and a == b and b == c:
			return a
	return EMPTY


## Returns the winning line indices if there's a winner, otherwise empty array
func get_winning_line() -> Array[int]:
	for line in WIN_LINES:
		var a: int = cells[line[0]]
		var b: int = cells[line[1]]
		var c: int = cells[line[2]]
		if a != EMPTY and a == b and b == c:
			var result: Array[int] = []
			result.assign(line)
			return result
	return []


## Checks if the board is full
func is_full() -> bool:
	for cell in cells:
		if cell == EMPTY:
			return false
	return true


## Checks if the game is over (win or draw)
func is_game_over() -> bool:
	return get_winner() != EMPTY or is_full()


## Checks if the game is a draw
func is_draw() -> bool:
	return is_full() and get_winner() == EMPTY


## Returns the opponent player
static func get_opponent(player: int) -> int:
	if player == PLAYER_X:
		return PLAYER_O
	elif player == PLAYER_O:
		return PLAYER_X
	return EMPTY


## Converts player constant to string representation
static func player_to_string(player: int) -> String:
	match player:
		PLAYER_X:
			return "X"
		PLAYER_O:
			return "O"
		_:
			return ""


## Converts string to player constant
static func string_to_player(s: String) -> int:
	match s.to_upper():
		"X":
			return PLAYER_X
		"O":
			return PLAYER_O
		_:
			return EMPTY


## Returns the number of moves made
func get_move_count() -> int:
	return move_history.size()


## Returns a string representation of the board (for debugging)
func to_string() -> String:
	var result := ""
	for i in range(9):
		match cells[i]:
			EMPTY:
				result += "."
			PLAYER_X:
				result += "X"
			PLAYER_O:
				result += "O"
		if i % 3 == 2 and i < 8:
			result += "\n"
	return result
