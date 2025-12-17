## AdMobAdsService.gd
## AdMob implementation using Poing Studios Godot AdMob plugin.
## Reference: https://poingstudios.github.io/godot-admob-plugin/
class_name AdMobAdsService
extends IAdsService

# Plugin singletons (will be null if plugin not available)
var _admob_plugin = null
var _is_initialized: bool = false
var _rewarded_ready: bool = false
var _banner_visible: bool = false

# Callbacks for rewarded ads
var _reward_callback: Callable
var _fail_callback: Callable

# Configuration
var _config: Dictionary = {}


func _init(config: Dictionary = {}) -> void:
	_config = config


## Initializes AdMob with the app configuration
func initialize() -> void:
	if _is_initialized:
		return

	# Check if AdMob plugin is available
	if not Engine.has_singleton("AdMob"):
		push_warning("AdMobAdsService: AdMob plugin not found. Ads will not work.")
		return

	_admob_plugin = Engine.get_singleton("AdMob")

	if _admob_plugin == null:
		push_warning("AdMobAdsService: Failed to get AdMob singleton.")
		return

	# Connect signals from the plugin
	_connect_signals()

	# Initialize AdMob
	# The plugin automatically reads the AdMob App ID from AndroidManifest.xml
	# or you can pass it via initialization config
	var init_config := {
		"is_for_child_directed_treatment": false,
		"is_real": not OS.is_debug_build(),  # Use test ads in debug
		"max_ad_content_rating": "G"
	}

	_admob_plugin.initialize(init_config)
	_is_initialized = true

	print("AdMobAdsService: Initialized successfully")


## Connects plugin signals to local handlers
func _connect_signals() -> void:
	if _admob_plugin == null:
		return

	# Banner signals
	if _admob_plugin.has_signal("banner_loaded"):
		_admob_plugin.banner_loaded.connect(_on_banner_loaded)
	if _admob_plugin.has_signal("banner_failed_to_load"):
		_admob_plugin.banner_failed_to_load.connect(_on_banner_failed)

	# Rewarded signals
	if _admob_plugin.has_signal("rewarded_ad_loaded"):
		_admob_plugin.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	if _admob_plugin.has_signal("rewarded_ad_failed_to_load"):
		_admob_plugin.rewarded_ad_failed_to_load.connect(_on_rewarded_failed_to_load)
	if _admob_plugin.has_signal("rewarded_ad_failed_to_show"):
		_admob_plugin.rewarded_ad_failed_to_show.connect(_on_rewarded_failed_to_show)
	if _admob_plugin.has_signal("user_earned_reward"):
		_admob_plugin.user_earned_reward.connect(_on_user_earned_reward)
	if _admob_plugin.has_signal("rewarded_ad_closed"):
		_admob_plugin.rewarded_ad_closed.connect(_on_rewarded_closed)

	# Consent signals (if UMP supported)
	if _admob_plugin.has_signal("consent_info_updated"):
		_admob_plugin.consent_info_updated.connect(_on_consent_updated)
	if _admob_plugin.has_signal("consent_form_dismissed"):
		_admob_plugin.consent_form_dismissed.connect(_on_consent_dismissed)


## Shows a banner ad
func show_banner(position: String = "bottom") -> void:
	if not _is_initialized or _admob_plugin == null:
		banner_failed.emit("AdMob not initialized")
		return

	var ad_unit_id: String = _config.get("banner_ad_unit_id", "")
	if ad_unit_id.is_empty():
		# Use test ad unit ID
		ad_unit_id = "ca-app-pub-3940256099942544/6300978111"  # Google test banner
		push_warning("AdMobAdsService: Using test banner ad unit ID")

	# Position: TOP or BOTTOM
	var pos_enum: int = 1 if position.to_lower() == "top" else 0  # 0 = BOTTOM, 1 = TOP

	# Banner size: BANNER (320x50)
	var size := "BANNER"

	_admob_plugin.load_banner({
		"ad_unit_id": ad_unit_id,
		"position": pos_enum,
		"size": size
	})

	_banner_visible = true
	print("AdMobAdsService: Loading banner ad")


## Hides the banner ad
func hide_banner() -> void:
	if not _is_initialized or _admob_plugin == null:
		return

	if _banner_visible:
		_admob_plugin.destroy_banner()
		_banner_visible = false
		print("AdMobAdsService: Banner hidden")


## Loads a rewarded ad
func load_rewarded(ad_unit_key: String = "rewarded") -> void:
	if not _is_initialized or _admob_plugin == null:
		rewarded_failed.emit("AdMob not initialized")
		return

	var ad_unit_id: String = _config.get("rewarded_ad_unit_id", "")
	if ad_unit_id.is_empty():
		# Use test ad unit ID
		ad_unit_id = "ca-app-pub-3940256099942544/5224354917"  # Google test rewarded
		push_warning("AdMobAdsService: Using test rewarded ad unit ID")

	_rewarded_ready = false
	_admob_plugin.load_rewarded({
		"ad_unit_id": ad_unit_id
	})

	print("AdMobAdsService: Loading rewarded ad")


## Checks if rewarded ad is ready
func is_rewarded_ready() -> bool:
	return _rewarded_ready


## Shows a rewarded ad
func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	if not _is_initialized or _admob_plugin == null:
		on_fail.call()
		return

	if not _rewarded_ready:
		rewarded_failed.emit("Rewarded ad not ready")
		on_fail.call()
		return

	_reward_callback = on_reward
	_fail_callback = on_fail

	_admob_plugin.show_rewarded()
	print("AdMobAdsService: Showing rewarded ad")


## Requests consent if required (GDPR/UMP)
func request_consent_if_required(on_done: Callable) -> void:
	if not _is_initialized or _admob_plugin == null:
		# Consent not available, proceed without blocking
		on_done.call()
		return

	# Check if plugin supports UMP
	if not _admob_plugin.has_method("request_consent_info_update"):
		# UMP not supported in this plugin version
		print("AdMobAdsService: UMP not supported, proceeding without consent")
		on_done.call()
		return

	# Store callback for when consent is done
	_consent_done_callback = on_done

	# Request consent info update
	_admob_plugin.request_consent_info_update({
		"debug_geography": 0,  # 0 = DISABLED, 1 = EEA, 2 = NOT_EEA
		"test_device_hashed_ids": []
	})

	print("AdMobAdsService: Requesting consent info")


var _consent_done_callback: Callable


## Returns if service is supported
func is_supported() -> bool:
	return Engine.has_singleton("AdMob")


## Returns if service is initialized
func is_initialized() -> bool:
	return _is_initialized


# Signal handlers

func _on_banner_loaded() -> void:
	print("AdMobAdsService: Banner loaded")
	banner_loaded.emit()


func _on_banner_failed(error_code: int) -> void:
	var error_msg := "Banner failed to load: " + str(error_code)
	print("AdMobAdsService: " + error_msg)
	banner_failed.emit(error_msg)


func _on_rewarded_loaded() -> void:
	print("AdMobAdsService: Rewarded ad loaded")
	_rewarded_ready = true
	rewarded_loaded.emit()


func _on_rewarded_failed_to_load(error_code: int) -> void:
	var error_msg := "Rewarded ad failed to load: " + str(error_code)
	print("AdMobAdsService: " + error_msg)
	_rewarded_ready = false
	rewarded_failed.emit(error_msg)


func _on_rewarded_failed_to_show(error_code: int) -> void:
	var error_msg := "Rewarded ad failed to show: " + str(error_code)
	print("AdMobAdsService: " + error_msg)
	if _fail_callback.is_valid():
		_fail_callback.call()
	rewarded_failed.emit(error_msg)


func _on_user_earned_reward(_reward_type: String, _reward_amount: int) -> void:
	print("AdMobAdsService: User earned reward - Type: %s, Amount: %d" % [_reward_type, _reward_amount])
	if _reward_callback.is_valid():
		_reward_callback.call()
	rewarded_earned.emit()


func _on_rewarded_closed() -> void:
	print("AdMobAdsService: Rewarded ad closed")
	_rewarded_ready = false
	# Preload next rewarded ad
	load_rewarded()
	rewarded_closed.emit()


func _on_consent_updated() -> void:
	print("AdMobAdsService: Consent info updated")
	# Check if consent form is needed
	if _admob_plugin.has_method("is_consent_form_available"):
		if _admob_plugin.is_consent_form_available():
			_admob_plugin.show_consent_form()
		else:
			_complete_consent(true)
	else:
		_complete_consent(true)


func _on_consent_dismissed() -> void:
	print("AdMobAdsService: Consent form dismissed")
	_complete_consent(true)


func _complete_consent(granted: bool) -> void:
	consent_completed.emit(granted)
	if _consent_done_callback.is_valid():
		_consent_done_callback.call()
