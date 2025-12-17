## TicTacToeAI.gd
## AI player for Tic-Tac-Toe with Easy, Medium, and Hard difficulty levels.
## Hard difficulty uses minimax with alpha-beta pruning (unbeatable).
class_name TicTacToeAI
extends RefCounted

enum Difficulty { EASY, MEDIUM, HARD }

# Current difficulty setting
var difficulty: Difficulty = Difficulty.MEDIUM

# The player marker this AI controls (PLAYER_X or PLAYER_O)
var ai_player: int = Board.PLAYER_O

# Opponent player marker
var opponent_player: int = Board.PLAYER_X

# Random number generator for non-deterministic behavior
var rng := RandomNumberGenerator.new()

# Medium difficulty: max depth for limited minimax
const MEDIUM_MAX_DEPTH: int = 3

# Easy difficulty: chance to make a random move instead of optimal
const EASY_RANDOM_CHANCE: float = 0.7


func _init(player: int = Board.PLAYER_O, diff: Difficulty = Difficulty.MEDIUM) -> void:
	ai_player = player
	opponent_player = Board.get_opponent(player)
	difficulty = diff
	rng.randomize()


## Sets the difficulty level
func set_difficulty(diff: Difficulty) -> void:
	difficulty = diff


## Sets which player the AI controls
func set_player(player: int) -> void:
	ai_player = player
	opponent_player = Board.get_opponent(player)


## Returns the best move for the current board state
## Returns -1 if no valid moves available
func get_best_move(board: Board) -> int:
	var legal_moves := board.get_legal_moves()
	if legal_moves.is_empty():
		return -1

	match difficulty:
		Difficulty.EASY:
			return _get_easy_move(board, legal_moves)
		Difficulty.MEDIUM:
			return _get_medium_move(board, legal_moves)
		Difficulty.HARD:
			return _get_hard_move(board, legal_moves)

	return legal_moves[0]


## Returns a hint move for the human player (best move from their perspective)
func get_hint_for_player(board: Board, player: int) -> int:
	var legal_moves := board.get_legal_moves()
	if legal_moves.is_empty():
		return -1

	# Temporarily set AI to play as the human to find their best move
	var original_player := ai_player
	var original_opponent := opponent_player
	ai_player = player
	opponent_player = Board.get_opponent(player)

	var best_move := _get_hard_move(board, legal_moves)

	# Restore original settings
	ai_player = original_player
	opponent_player = original_opponent

	return best_move


## Easy difficulty: mostly random, but takes obvious wins
func _get_easy_move(board: Board, legal_moves: Array[int]) -> int:
	# Check for immediate win
	var winning_move := _find_winning_move(board, ai_player)
	if winning_move != -1:
		return winning_move

	# Occasionally block opponent's winning move
	if rng.randf() > EASY_RANDOM_CHANCE:
		var blocking_move := _find_winning_move(board, opponent_player)
		if blocking_move != -1:
			return blocking_move

	# Otherwise random
	return legal_moves[rng.randi() % legal_moves.size()]


## Medium difficulty: limited depth minimax with some randomness
func _get_medium_move(board: Board, legal_moves: Array[int]) -> int:
	# Always take winning move if available
	var winning_move := _find_winning_move(board, ai_player)
	if winning_move != -1:
		return winning_move

	# Always block opponent's winning move
	var blocking_move := _find_winning_move(board, opponent_player)
	if blocking_move != -1:
		return blocking_move

	# Use limited-depth minimax
	var best_move: int = -1
	var best_score: int = -1000

	for move in legal_moves:
		var test_board := board.duplicate_board()
		test_board.apply_move(move, ai_player)
		var score := _minimax(test_board, MEDIUM_MAX_DEPTH, false, -1000, 1000)

		# Add some randomness to make it beatable
		score += rng.randi_range(-1, 1)

		if score > best_score:
			best_score = score
			best_move = move

	return best_move if best_move != -1 else legal_moves[0]


## Hard difficulty: full minimax with alpha-beta pruning (unbeatable)
func _get_hard_move(board: Board, legal_moves: Array[int]) -> int:
	var best_move: int = -1
	var best_score: int = -1000

	for move in legal_moves:
		var test_board := board.duplicate_board()
		test_board.apply_move(move, ai_player)
		var score := _minimax(test_board, 9, false, -1000, 1000)

		if score > best_score:
			best_score = score
			best_move = move

	return best_move if best_move != -1 else legal_moves[0]


## Minimax algorithm with alpha-beta pruning
## Returns the evaluation score for the given board state
func _minimax(board: Board, depth: int, is_maximizing: bool, alpha: int, beta: int) -> int:
	# Terminal state checks
	var winner := board.get_winner()
	if winner == ai_player:
		return 10 + depth  # Prefer faster wins
	elif winner == opponent_player:
		return -10 - depth  # Prefer slower losses
	elif board.is_full() or depth == 0:
		return 0  # Draw or depth limit

	var legal_moves := board.get_legal_moves()

	if is_maximizing:
		var max_score: int = -1000
		for move in legal_moves:
			var test_board := board.duplicate_board()
			test_board.apply_move(move, ai_player)
			var score := _minimax(test_board, depth - 1, false, alpha, beta)
			max_score = max(max_score, score)
			alpha = max(alpha, score)
			if beta <= alpha:
				break  # Beta cutoff
		return max_score
	else:
		var min_score: int = 1000
		for move in legal_moves:
			var test_board := board.duplicate_board()
			test_board.apply_move(move, opponent_player)
			var score := _minimax(test_board, depth - 1, true, alpha, beta)
			min_score = min(min_score, score)
			beta = min(beta, score)
			if beta <= alpha:
				break  # Alpha cutoff
		return min_score


## Finds a winning move for the specified player
## Returns the cell index or -1 if no winning move exists
func _find_winning_move(board: Board, player: int) -> int:
	var legal_moves := board.get_legal_moves()
	for move in legal_moves:
		var test_board := board.duplicate_board()
		test_board.apply_move(move, player)
		if test_board.get_winner() == player:
			return move
	return -1


## Static helper to convert difficulty enum to string
static func difficulty_to_string(diff: Difficulty) -> String:
	match diff:
		Difficulty.EASY:
			return "Easy"
		Difficulty.MEDIUM:
			return "Medium"
		Difficulty.HARD:
			return "Hard"
	return "Unknown"


## Static helper to convert string to difficulty enum
static func string_to_difficulty(s: String) -> Difficulty:
	match s.to_lower():
		"easy":
			return Difficulty.EASY
		"medium":
			return Difficulty.MEDIUM
		"hard":
			return Difficulty.HARD
	return Difficulty.MEDIUM
