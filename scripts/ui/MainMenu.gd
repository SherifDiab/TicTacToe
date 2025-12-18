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
	print("MainMenu: _ready() called")

	# Verify nodes exist
	if play_button == null:
		push_error("MainMenu: PlayButton not found!")
		return

	print("MainMenu: PlayButton found: ", play_button)

	_setup_options()
	_connect_signals()
	_update_stats_display()

	print("MainMenu: Initialization complete")
	
	# Show banner ad on menu
	if AdsConfig.SHOW_BANNER_ON_MENU:
		print("MainMenu: Show Banner")
		AdsManager.show_banner()

func _on_initialization_complete(initialization_status : InitializationStatus) -> void:
	print("MobileAds initialization complete")
	print_all_values(initialization_status)
	var ad_colony_app_options := AdColonyAppOptions.new()
	print("set values ad_colony")
	ad_colony_app_options.set_privacy_consent_string(AdColonyAppOptions.CCPA, "STRIaNG CCPA")
	ad_colony_app_options.set_privacy_framework_required(AdColonyAppOptions.CCPA, false)
	ad_colony_app_options.set_user_id("asdaaaad")
	ad_colony_app_options.set_test_mode(false)
	
	print(ad_colony_app_options.get_privacy_consent_string(AdColonyAppOptions.CCPA))
	print(ad_colony_app_options.get_privacy_framework_required(AdColonyAppOptions.CCPA))
	print(ad_colony_app_options.get_user_id())
	print(ad_colony_app_options.get_test_mode())
	
	if OS.get_name() == "iOS":
		#FBAdSettings is available only for iOS, Google didn't put this method on Android SDK
		FBAdSettings.set_advertiser_tracking_enabled(true)
		
	Vungle.update_ccpa_status(Vungle.Consent.OPTED_IN)
	Vungle.update_ccpa_status(Vungle.Consent.OPTED_OUT)
	Vungle.update_consent_status(Vungle.Consent.OPTED_IN, "message1")
	Vungle.update_consent_status(Vungle.Consent.OPTED_OUT, "message2")

func print_all_values(initialization_status : InitializationStatus) -> void:
	for key in initialization_status.adapter_status_map:
		var adapterStatus : AdapterStatus = initialization_status.adapter_status_map[key]
		prints("Key:", key, "Latency:", adapterStatus.latency, "Initialization State:", adapterStatus.initialization_state, "Description:", adapterStatus.description)

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
	print("MainMenu: Connecting signals...")

	play_button.pressed.connect(_on_play_pressed)
	print("MainMenu: Play button signal connected")

	quit_button.pressed.connect(_on_quit_pressed)
	reset_stats_button.pressed.connect(_on_reset_stats_pressed)
	reset_confirm_dialog.confirmed.connect(_on_reset_confirmed)
	difficulty_option.item_selected.connect(_on_difficulty_changed)
	symbol_option.item_selected.connect(_on_symbol_changed)

	# Update stats when they change
	StatsStore.stats_updated.connect(_update_stats_display)

	print("MainMenu: All signals connected")


## Updates the statistics display
func _update_stats_display() -> void:
	stats_label.text = StatsStore.get_stats_summary()


## Called when play button is pressed
func _on_play_pressed() -> void:
	print("MainMenu: Play button pressed")

	# Disable play button to prevent double-clicks
	play_button.disabled = true

	# Apply settings to GameManager
	var diff_index := difficulty_option.selected
	var difficulty: TicTacToeAI.Difficulty = TicTacToeAI.Difficulty.MEDIUM
	match diff_index:
		0:
			difficulty = TicTacToeAI.Difficulty.EASY
		1:
			difficulty = TicTacToeAI.Difficulty.MEDIUM
		2:
			difficulty = TicTacToeAI.Difficulty.HARD
		_:
			difficulty = TicTacToeAI.Difficulty.MEDIUM

	GameManager.set_difficulty(difficulty)

	var symbol_index := symbol_option.selected
	var symbol: int = Board.PLAYER_X if symbol_index == 0 else Board.PLAYER_O
	GameManager.set_player_symbol(symbol)

	# Hide banner before showing interstitial
	AdsManager.hide_banner()

	# Show interstitial ad before game if enabled
	if AdsConfig.SHOW_INTERSTITIAL_BEFORE_GAME:
		print("MainMenu: Showing interstitial ad before game")
		AdsManager.show_interstitial(_start_game)
	else:
		_start_game()


## Starts the game after ad is closed (or immediately if no ad)
func _start_game() -> void:
	print("MainMenu: Starting new game and transitioning to Game scene")
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
	var difficulty: TicTacToeAI.Difficulty = TicTacToeAI.Difficulty.MEDIUM
	match index:
		0:
			difficulty = TicTacToeAI.Difficulty.EASY
		1:
			difficulty = TicTacToeAI.Difficulty.MEDIUM
		2:
			difficulty = TicTacToeAI.Difficulty.HARD
		_:
			difficulty = TicTacToeAI.Difficulty.MEDIUM

	GameManager.set_difficulty(difficulty)


## Called when symbol option changes
func _on_symbol_changed(index: int) -> void:
	var symbol: int = Board.PLAYER_X if index == 0 else Board.PLAYER_O
	GameManager.set_player_symbol(symbol)
