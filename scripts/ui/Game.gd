## Game.gd
## Game scene controller.
## Manages the game board UI, player input, and game flow.
extends Control

# Colors
const COLOR_X := Color(0.3, 0.8, 0.77, 1)       # Cyan for X
const COLOR_O := Color(1.0, 0.42, 0.42, 1)     # Red for O
const COLOR_EMPTY := Color(0.25, 0.25, 0.28, 1)
const COLOR_WIN := Color(0.3, 0.9, 0.4, 1)     # Green highlight for winning cells
const COLOR_HINT := Color(1.0, 0.85, 0.0, 0.5) # Yellow highlight for hint
const COLOR_DISABLED := Color(0.4, 0.4, 0.4, 1)

# Node references
@onready var back_button: Button = %BackButton
@onready var difficulty_label: Label = %DifficultyLabel
@onready var status_label: Label = %StatusLabel
@onready var grid_container: GridContainer = %GridContainer
@onready var restart_button: Button = %RestartButton
@onready var hint_button: Button = %HintButton
@onready var ai_thinking_timer: Timer = %AIThinkingTimer
@onready var hint_clear_timer: Timer = %HintClearTimer
@onready var game_over_panel: Control = %GameOverPanel

# Cell buttons array
var cell_buttons: Array[Button] = []

# Game controller reference
var game_controller: GameController

# Current hint cell (for clearing)
var _hint_cell_index: int = -1

# Original cell colors (for restoring after hint)
var _original_cell_colors: Array[Color] = []


func _ready() -> void:
	# Get game controller from GameManager
	game_controller = GameManager.get_game_controller()

	# Setup cell buttons
	_setup_cells()

	# Connect signals
	_connect_signals()

	# Update initial state
	_update_display()

	# If AI starts first, trigger AI move
	if game_controller.is_ai_turn():
		_schedule_ai_move()


## Sets up the cell buttons
func _setup_cells() -> void:
	cell_buttons.clear()
	_original_cell_colors.clear()

	for i in range(9):
		var cell: Button = grid_container.get_node("Cell" + str(i))
		cell_buttons.append(cell)
		_original_cell_colors.append(COLOR_EMPTY)

		# Connect cell press
		var cell_index := i
		cell.pressed.connect(_on_cell_pressed.bind(cell_index))

		# Set initial style
		_update_cell_display(i)


## Connects signals
func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	ai_thinking_timer.timeout.connect(_on_ai_thinking_timeout)
	hint_clear_timer.timeout.connect(_on_hint_clear_timeout)

	# Game controller signals
	game_controller.move_made.connect(_on_move_made)
	game_controller.turn_changed.connect(_on_turn_changed)
	game_controller.game_over.connect(_on_game_over)
	game_controller.hint_available.connect(_on_hint_available)


## Updates the entire display
func _update_display() -> void:
	# Update difficulty label
	difficulty_label.text = GameManager.get_difficulty_string()

	# Update status
	_update_status_label()

	# Update all cells
	for i in range(9):
		_update_cell_display(i)

	# Update button states
	_update_button_states()


## Updates a single cell display
func _update_cell_display(cell_index: int) -> void:
	var cell := cell_buttons[cell_index]
	var board := game_controller.get_board()
	var value := board.get_cell(cell_index)

	match value:
		Board.EMPTY:
			cell.text = ""
			_set_cell_color(cell, COLOR_EMPTY)
		Board.PLAYER_X:
			cell.text = "X"
			_set_cell_color(cell, COLOR_X)
		Board.PLAYER_O:
			cell.text = "O"
			_set_cell_color(cell, COLOR_O)


## Sets cell button color
func _set_cell_color(cell: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	cell.add_theme_stylebox_override("normal", style)

	# Hover and pressed states
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = color.lightened(0.15)
	hover_style.set_corner_radius_all(8)
	cell.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = color.darkened(0.15)
	pressed_style.set_corner_radius_all(8)
	cell.add_theme_stylebox_override("pressed", pressed_style)


## Updates the status label
func _update_status_label() -> void:
	var info := game_controller.get_game_info()
	var current_turn: int = info["current_turn"]
	var human_player: int = info["human_player"]
	var symbol := Board.player_to_string(current_turn)

	if info["state"] == GameController.GameState.GAME_OVER:
		var winner := game_controller.get_winner()
		if winner == Board.EMPTY:
			status_label.text = "It's a Draw!"
		elif winner == human_player:
			status_label.text = "You Win!"
		else:
			status_label.text = "You Lose!"
	elif current_turn == human_player:
		status_label.text = "Your Turn (%s)" % symbol
	else:
		status_label.text = "AI Thinking..."


## Updates button states
func _update_button_states() -> void:
	var info := game_controller.get_game_info()
	var is_playing := info["state"] == GameController.GameState.PLAYING
	var is_human_turn := info["current_turn"] == info["human_player"]

	# Enable/disable cells based on game state
	var board := game_controller.get_board()
	for i in range(9):
		var cell := cell_buttons[i]
		var can_click := is_playing and is_human_turn and board.is_legal_move(i)
		cell.disabled = not can_click

	# Hint button only during human turn
	hint_button.disabled = not (is_playing and is_human_turn)


## Highlights winning cells
func _highlight_winning_line() -> void:
	var winning_line := game_controller.get_winning_line()
	for cell_index in winning_line:
		var cell := cell_buttons[cell_index]
		_set_cell_color(cell, COLOR_WIN)
		cell.add_theme_color_override("font_color", Color.WHITE)


## Schedules AI move with delay
func _schedule_ai_move() -> void:
	ai_thinking_timer.start()


## Called when a cell is pressed
func _on_cell_pressed(cell_index: int) -> void:
	if game_controller.try_move(cell_index):
		_clear_hint()


## Called when move is made
func _on_move_made(cell_index: int, player: int) -> void:
	_update_cell_display(cell_index)
	_update_status_label()
	_update_button_states()


## Called when turn changes
func _on_turn_changed(current_player: int) -> void:
	_update_status_label()
	_update_button_states()

	# Schedule AI move if it's AI's turn
	if game_controller.is_ai_turn():
		_schedule_ai_move()


## Called when game is over
func _on_game_over(result: String, winner: int) -> void:
	_update_status_label()
	_update_button_states()

	# Highlight winning line
	if result == "win":
		_highlight_winning_line()

	# Record result to stats
	GameManager.record_game_result()

	# Show game over panel after short delay
	await get_tree().create_timer(0.5).timeout
	_show_game_over_panel(result, winner)


## Shows the game over panel
func _show_game_over_panel(result: String, winner: int) -> void:
	var human_player := game_controller.get_game_info()["human_player"]
	var human_won := winner == human_player
	var is_draw := result == "draw"

	game_over_panel.show_result(is_draw, human_won, game_controller.can_use_rewarded())
	game_over_panel.visible = true


## Called when AI thinking timer times out
func _on_ai_thinking_timeout() -> void:
	game_controller.request_ai_move()


## Called when back button is pressed
func _on_back_pressed() -> void:
	GameManager.go_to_main_menu()


## Called when restart button is pressed
func _on_restart_pressed() -> void:
	# Hide game over panel if visible
	game_over_panel.visible = false

	# Restart game
	game_controller.restart_game()
	_update_display()

	# If AI starts first
	if game_controller.is_ai_turn():
		_schedule_ai_move()


## Called when hint button is pressed
func _on_hint_pressed() -> void:
	game_controller.request_hint()


## Called when hint is available
func _on_hint_available(cell_index: int) -> void:
	_show_hint(cell_index)


## Shows hint on a cell
func _show_hint(cell_index: int) -> void:
	_clear_hint()

	_hint_cell_index = cell_index
	var cell := cell_buttons[cell_index]

	# Highlight the hint cell
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_HINT
	style.set_corner_radius_all(8)
	style.border_width_bottom = 3
	style.border_width_top = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_color = Color(1.0, 0.85, 0.0, 1)
	cell.add_theme_stylebox_override("normal", style)

	# Start timer to clear hint
	hint_clear_timer.start()


## Clears hint highlight
func _clear_hint() -> void:
	if _hint_cell_index >= 0:
		_update_cell_display(_hint_cell_index)
		_hint_cell_index = -1


## Called when hint clear timer times out
func _on_hint_clear_timeout() -> void:
	_clear_hint()


## Called from game over panel to perform undo (rewarded action)
func perform_rewarded_undo() -> void:
	if game_controller.perform_undo():
		game_controller.use_rewarded()
		game_over_panel.visible = false
		_update_display()

		# If it's now human's turn, allow input
		if not game_controller.is_ai_turn():
			_update_button_states()


## Called from game over panel to show hint (rewarded action)
func perform_rewarded_hint() -> void:
	game_controller.use_rewarded()
	var hint_move := game_controller.request_hint()
	if hint_move >= 0:
		_show_hint(hint_move)
