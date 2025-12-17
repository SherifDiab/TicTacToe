## AdsManager.gd
## Global ads manager autoload.
## Provides a unified interface for ads across the application.
extends Node

# Signals (proxied from ads service)
signal banner_loaded
signal banner_failed(error: String)
signal interstitial_loaded
signal interstitial_failed(error: String)
signal interstitial_closed
signal rewarded_loaded
signal rewarded_failed(error: String)
signal rewarded_earned
signal rewarded_closed
signal consent_completed(granted: bool)

# The ads service instance (dynamic typing to avoid class_name load order issues)
var _ads_service = null

# Configuration
var _config: Dictionary = {}

# State
var _is_ready: bool = false
var _consent_obtained: bool = false


func _ready() -> void:
	print("AdsManager: _ready() called")

	# Load configuration
	_config = AdsConfig.get_config()

	# Print config status in debug builds
	if OS.is_debug_build():
		AdsConfig.print_config_status()

	# Create appropriate ads service
	_ads_service = AdsServiceFactory.create_ads_service(_config)
	print("AdsManager: Ads service created: ", _ads_service)

	# Connect signals
	_connect_signals()

	# Initialize
	_initialize_ads()

	print("AdsManager: Initialization complete")


## Connects signals from the ads service
func _connect_signals() -> void:
	if _ads_service == null:
		return

	_ads_service.banner_loaded.connect(_on_banner_loaded)
	_ads_service.banner_failed.connect(_on_banner_failed)
	_ads_service.interstitial_loaded.connect(_on_interstitial_loaded)
	_ads_service.interstitial_failed.connect(_on_interstitial_failed)
	_ads_service.interstitial_closed.connect(_on_interstitial_closed)
	_ads_service.rewarded_loaded.connect(_on_rewarded_loaded)
	_ads_service.rewarded_failed.connect(_on_rewarded_failed)
	_ads_service.rewarded_earned.connect(_on_rewarded_earned)
	_ads_service.rewarded_closed.connect(_on_rewarded_closed)
	_ads_service.consent_completed.connect(_on_consent_completed)


## Initializes the ads system
func _initialize_ads() -> void:
	if _ads_service == null:
		return

	# Request consent first, then initialize
	_ads_service.request_consent_if_required(_on_consent_done)


## Called when consent flow is complete
func _on_consent_done() -> void:
	_consent_obtained = true

	# Now initialize ads
	_ads_service.initialize()
	_is_ready = true

	# Preload ads if configured
	if _config.get("preload_interstitial", true):
		_ads_service.load_interstitial()

	if _config.get("preload_rewarded", true):
		_ads_service.load_rewarded()

	print("AdsManager: Ready")


## Shows banner ad at specified position
func show_banner(position: String = "") -> void:
	if not _is_ready or _ads_service == null:
		return

	var pos: String = position if not position.is_empty() else str(_config.get("banner_position", "bottom"))
	_ads_service.show_banner(pos)


## Hides banner ad
func hide_banner() -> void:
	if _ads_service == null:
		return

	_ads_service.hide_banner()


## Loads an interstitial ad
func load_interstitial() -> void:
	if not _is_ready or _ads_service == null:
		return

	_ads_service.load_interstitial()


## Checks if interstitial ad is ready
func is_interstitial_ready() -> bool:
	if _ads_service == null:
		return false

	return _ads_service.is_interstitial_ready()


## Shows interstitial ad with callback when closed
func show_interstitial(on_close: Callable) -> void:
	if not _is_ready or _ads_service == null:
		on_close.call()
		return

	_ads_service.show_interstitial(on_close)


## Loads a rewarded ad
func load_rewarded() -> void:
	if not _is_ready or _ads_service == null:
		return

	_ads_service.load_rewarded()


## Checks if rewarded ad is ready
func is_rewarded_ready() -> bool:
	if _ads_service == null:
		return false

	return _ads_service.is_rewarded_ready()


## Shows rewarded ad with callbacks
func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	if not _is_ready or _ads_service == null:
		on_fail.call()
		return

	_ads_service.show_rewarded(on_reward, on_fail)


## Checks if ads are supported
func is_ads_supported() -> bool:
	return AdsServiceFactory.is_ads_supported()


## Checks if ads manager is ready
func is_ready() -> bool:
	return _is_ready


## Gets platform name
func get_platform() -> String:
	return AdsServiceFactory.get_platform_name()


# Signal handlers (proxy to our signals)

func _on_banner_loaded() -> void:
	banner_loaded.emit()


func _on_banner_failed(error: String) -> void:
	banner_failed.emit(error)


func _on_interstitial_loaded() -> void:
	interstitial_loaded.emit()


func _on_interstitial_failed(error: String) -> void:
	interstitial_failed.emit(error)


func _on_interstitial_closed() -> void:
	interstitial_closed.emit()


func _on_rewarded_loaded() -> void:
	rewarded_loaded.emit()


func _on_rewarded_failed(error: String) -> void:
	rewarded_failed.emit(error)


func _on_rewarded_earned() -> void:
	rewarded_earned.emit()


func _on_rewarded_closed() -> void:
	rewarded_closed.emit()


func _on_consent_completed(granted: bool) -> void:
	consent_completed.emit(granted)
