## GameOverPanel.gd
## Game over panel controller.
## Shows game result and rewarded ad option for undo.
extends Control

# Node references
@onready var result_label: Label = %ResultLabel
@onready var subtext_label: Label = %SubtextLabel
@onready var play_again_button: Button = %PlayAgainButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var rewarded_button: Button = %RewardedButton
@onready var ad_status_label: Label = %AdStatusLabel

# Reference to parent game scene
var _game_scene: Control = null

# Whether rewarded action is available
var _rewarded_available: bool = false


func _ready() -> void:
	_connect_signals()
	_update_rewarded_button_state()


## Connects button signals
func _connect_signals() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	rewarded_button.pressed.connect(_on_rewarded_pressed)

	# Listen for rewarded ad events
	AdsManager.rewarded_loaded.connect(_on_rewarded_loaded)
	AdsManager.rewarded_failed.connect(_on_rewarded_failed)


## Shows the result in the panel
func show_result(is_draw: bool, human_won: bool, can_use_rewarded: bool) -> void:
	_rewarded_available = can_use_rewarded

	# Get reference to parent game scene
	_game_scene = get_parent()

	# Update result display
	if is_draw:
		result_label.text = "DRAW"
		result_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2, 1))
		subtext_label.text = "It's a tie!"
	elif human_won:
		result_label.text = "YOU WIN!"
		result_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4, 1))
		subtext_label.text = "Congratulations!"
	else:
		result_label.text = "YOU LOSE"
		result_label.add_theme_color_override("font_color", Color(1.0, 0.42, 0.42, 1))
		subtext_label.text = "Better luck next time!"

	# Update rewarded button
	_update_rewarded_button_state()

	# Show banner ad on game over
	if AdsConfig.SHOW_BANNER_ON_GAME_OVER:
		AdsManager.show_banner()


## Updates the rewarded button state
func _update_rewarded_button_state() -> void:
	if not _rewarded_available:
		rewarded_button.visible = false
		ad_status_label.text = "Undo already used this match"
		ad_status_label.visible = true
		return

	rewarded_button.visible = true

	if AdsManager.is_rewarded_ready():
		rewarded_button.disabled = false
		rewarded_button.text = "Watch Ad for Undo"
		ad_status_label.text = ""
		ad_status_label.visible = false
	else:
		rewarded_button.disabled = true
		rewarded_button.text = "Loading Ad..."
		ad_status_label.text = "Ad not available yet"
		ad_status_label.visible = true

		# Try to load rewarded ad
		AdsManager.load_rewarded()


## Called when play again button is pressed
func _on_play_again_pressed() -> void:
	# Hide banner
	AdsManager.hide_banner()

	# Tell parent to restart
	if _game_scene and _game_scene.has_method("_on_restart_pressed"):
		_game_scene._on_restart_pressed()


## Called when main menu button is pressed
func _on_main_menu_pressed() -> void:
	# Hide banner
	AdsManager.hide_banner()

	# Go to main menu
	GameManager.go_to_main_menu()


## Called when rewarded button is pressed
func _on_rewarded_pressed() -> void:
	if not _rewarded_available:
		return

	if not AdsManager.is_rewarded_ready():
		ad_status_label.text = "Ad not ready, please wait..."
		ad_status_label.visible = true
		return

	# Disable button while showing ad
	rewarded_button.disabled = true
	rewarded_button.text = "Showing Ad..."

	# Show rewarded ad
	AdsManager.show_rewarded(_on_reward_earned, _on_reward_failed)


## Called when reward is earned
func _on_reward_earned() -> void:
	print("GameOverPanel: Reward earned - performing undo")

	# Hide banner before returning to game
	AdsManager.hide_banner()

	# Perform the undo action
	if _game_scene and _game_scene.has_method("perform_rewarded_undo"):
		_game_scene.perform_rewarded_undo()

	# Hide this panel
	visible = false


## Called when reward fails
func _on_reward_failed() -> void:
	print("GameOverPanel: Reward failed")
	ad_status_label.text = "Ad failed to show. Try again."
	ad_status_label.visible = true
	_update_rewarded_button_state()


## Called when rewarded ad is loaded
func _on_rewarded_loaded() -> void:
	if visible and _rewarded_available:
		_update_rewarded_button_state()


## Called when rewarded ad fails to load
func _on_rewarded_failed(error: String) -> void:
	if visible:
		ad_status_label.text = "Ad not available"
		ad_status_label.visible = true
		rewarded_button.disabled = true
		rewarded_button.text = "Ad Unavailable"
