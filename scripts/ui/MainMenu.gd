## MainMenu.gd
## Main menu scene controller.
## Handles difficulty/symbol selection, stats display, and navigation.
extends Control

# Node references
@onready var difficulty_option: OptionButton = %DifficultyOption
@onready var symbol_option: OptionButton = %SymbolOption
@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var stats_label: Label = %StatsLabel
@onready var reset_stats_button: Button = %ResetStatsButton
@onready var reset_confirm_dialog: ConfirmationDialog = %ResetConfirmDialog


func _ready() -> void:
	_setup_options()
	_connect_signals()
	_update_stats_display()

	# Show banner ad on menu
	if AdsConfig.SHOW_BANNER_ON_MENU:
		AdsManager.show_banner()


func _exit_tree() -> void:
	# Hide banner when leaving menu
	AdsManager.hide_banner()


## Sets up the option buttons
func _setup_options() -> void:
	# Difficulty options
	difficulty_option.clear()
	difficulty_option.add_item("Easy", 0)
	difficulty_option.add_item("Medium", 1)
	difficulty_option.add_item("Hard", 2)
	difficulty_option.select(1)  # Default to Medium

	# Symbol options
	symbol_option.clear()
	symbol_option.add_item("X (First)", 0)
	symbol_option.add_item("O (Second)", 1)
	symbol_option.select(0)  # Default to X


## Connects button signals
func _connect_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	reset_stats_button.pressed.connect(_on_reset_stats_pressed)
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	difficulty_option.item_selected.connect(_on_difficulty_changed)
	symbol_option.item_selected.connect(_on_symbol_changed)

	# Update stats when they change
	StatsStore.stats_updated.connect(_update_stats_display)


## Updates the statistics display
func _update_stats_display() -> void:
	stats_label.text = StatsStore.get_stats_summary()


## Called when play button is pressed
func _on_play_pressed() -> void:
	# Apply settings to GameManager
	var diff_index := difficulty_option.selected
	var difficulty: TicTacToeAI.Difficulty
	match diff_index:
		0:
			difficulty = TicTacToeAI.Difficulty.EASY
		1:
			difficulty = TicTacToeAI.Difficulty.MEDIUM
		2:
			difficulty = TicTacToeAI.Difficulty.HARD

	GameManager.set_difficulty(difficulty)

	var symbol_index := symbol_option.selected
	var symbol: int = Board.PLAYER_X if symbol_index == 0 else Board.PLAYER_O
	GameManager.set_player_symbol(symbol)

	# Hide banner before transitioning
	AdsManager.hide_banner()

	# Start game and go to game scene
	GameManager.start_new_game()
	GameManager.go_to_game()


## Called when quit button is pressed
func _on_quit_pressed() -> void:
	GameManager.quit_game()


## Called when reset stats button is pressed
func _on_reset_stats_pressed() -> void:
	reset_confirm_dialog.popup_centered()


## Called when reset is confirmed
func _on_reset_confirmed() -> void:
	StatsStore.reset_stats()


## Called when difficulty option changes
func _on_difficulty_changed(index: int) -> void:
	var difficulty: TicTacToeAI.Difficulty
	match index:
		0:
			difficulty = TicTacToeAI.Difficulty.EASY
		1:
			difficulty = TicTacToeAI.Difficulty.MEDIUM
		2:
			difficulty = TicTacToeAI.Difficulty.HARD

	GameManager.set_difficulty(difficulty)


## Called when symbol option changes
func _on_symbol_changed(index: int) -> void:
	var symbol: int = Board.PLAYER_X if index == 0 else Board.PLAYER_O
	GameManager.set_player_symbol(symbol)
