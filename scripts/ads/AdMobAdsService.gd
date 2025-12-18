## AdMobAdsService.gd
## AdMob implementation using Poing Studios Godot AdMob plugin (new API v1.0.1+).
## Reference: https://github.com/poing-studios/godot-admob-android
class_name AdMobAdsService
extends RefCounted

# Signals for ad events (matching IAdsService interface)
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

# State
var _is_initialized: bool = false
var _interstitial_ready: bool = false
var _rewarded_ready: bool = false
var _banner_visible: bool = false

# Ad objects (using new Poing AdMob API)
var _ad_view: AdView = null
var _interstitial_ad: InterstitialAd = null
var _rewarded_ad: RewardedAd = null

# Callbacks for ads
var _interstitial_close_callback: Callable
var _reward_callback: Callable
var _fail_callback: Callable

# Configuration
var _config: Dictionary = {}


func _init(config: Dictionary = {}) -> void:
	_config = config


## Check if the Poing AdMob plugin is available
static func is_plugin_available() -> bool:
	# The new Poing AdMob plugin uses PoingGodotAdMob as its main singleton
	return Engine.has_singleton("PoingGodotAdMob")


## Initializes AdMob with the app configuration
func initialize() -> void:
	if _is_initialized:
		return

	print("AdMobAdsService: Initializing with new Poing AdMob API...")
	print("AdMobAdsService: Platform = ", OS.get_name())

	# Check if plugin is available
	if not is_plugin_available():
		push_error("AdMobAdsService: PoingGodotAdMob plugin not found!")
		return

	print("AdMobAdsService: PoingGodotAdMob plugin FOUND!")

	# Create initialization listener
	var init_listener := OnInitializationCompleteListener.new()
	init_listener.on_initialization_complete = _on_initialization_complete

	# Initialize MobileAds
	MobileAds.initialize(init_listener)

	_is_initialized = true
	print("AdMobAdsService: Initialization request sent")


func _on_initialization_complete(initialization_status: InitializationStatus) -> void:
	print("AdMobAdsService: Initialization complete!")
	if initialization_status:
		print("AdMobAdsService: Adapter statuses available")


## Shows a banner ad
func show_banner(position: String = "bottom") -> void:
	print("AdMobAdsService: show_banner() called, position=", position)

	if not _is_initialized:
		print("AdMobAdsService: Cannot show banner - not initialized!")
		banner_failed.emit("AdMob not initialized")
		return

	# Destroy existing banner if any
	if _ad_view != null:
		_ad_view.destroy()
		_ad_view = null

	var ad_unit_id: String = str(_config.get("banner_ad_unit_id", ""))
	if ad_unit_id.is_empty():
		ad_unit_id = "ca-app-pub-3940256099942544/6300978111"  # Google test banner
		print("AdMobAdsService: Using test banner ad unit ID")

	# Determine position
	var ad_position: int = AdPosition.Values.BOTTOM
	if position.to_lower() == "top":
		ad_position = AdPosition.Values.TOP

	# Get adaptive banner size
	var ad_size := AdSize.get_current_orientation_anchored_adaptive_banner_ad_size(AdSize.FULL_WIDTH)
	print("AdMobAdsService: Banner size: ", ad_size.width, "x", ad_size.height)

	# Create AdView
	_ad_view = AdView.new(ad_unit_id, ad_size, ad_position)

	# Set up listener
	var ad_listener := AdListener.new()
	ad_listener.on_ad_loaded = _on_banner_loaded
	ad_listener.on_ad_failed_to_load = _on_banner_failed_to_load
	ad_listener.on_ad_clicked = func(): print("AdMobAdsService: Banner clicked")
	ad_listener.on_ad_opened = func(): print("AdMobAdsService: Banner opened")
	ad_listener.on_ad_closed = func(): print("AdMobAdsService: Banner closed")
	ad_listener.on_ad_impression = func(): print("AdMobAdsService: Banner impression")
	_ad_view.ad_listener = ad_listener

	# Load the ad
	var ad_request := AdRequest.new()
	_ad_view.load_ad(ad_request)
	_banner_visible = true
	print("AdMobAdsService: Banner load request sent")


func _on_banner_loaded() -> void:
	print("AdMobAdsService: Banner loaded successfully!")
	banner_loaded.emit()


func _on_banner_failed_to_load(error: LoadAdError) -> void:
	var error_msg := "Banner failed to load: " + str(error.message) if error else "Unknown error"
	print("AdMobAdsService: ", error_msg)
	banner_failed.emit(error_msg)


## Hides the banner ad
func hide_banner() -> void:
	if _ad_view != null:
		_ad_view.hide()
		_banner_visible = false
		print("AdMobAdsService: Banner hidden")


## Destroys the banner ad
func destroy_banner() -> void:
	if _ad_view != null:
		_ad_view.destroy()
		_ad_view = null
		_banner_visible = false
		print("AdMobAdsService: Banner destroyed")


## Loads an interstitial ad
func load_interstitial(ad_unit_key: String = "interstitial") -> void:
	print("AdMobAdsService: load_interstitial() called")

	if not _is_initialized:
		print("AdMobAdsService: Cannot load interstitial - not initialized!")
		interstitial_failed.emit("AdMob not initialized")
		return

	var ad_unit_id: String = str(_config.get("interstitial_ad_unit_id", ""))
	if ad_unit_id.is_empty():
		ad_unit_id = "ca-app-pub-3940256099942544/1033173712"  # Google test interstitial
		print("AdMobAdsService: Using test interstitial ad unit ID")

	_interstitial_ready = false

	# Create load callback
	var load_callback := InterstitialAdLoadCallback.new()
	load_callback.on_ad_loaded = _on_interstitial_ad_loaded
	load_callback.on_ad_failed_to_load = _on_interstitial_ad_failed_to_load

	# Load the ad
	InterstitialAdLoader.new().load(ad_unit_id, AdRequest.new(), load_callback)
	print("AdMobAdsService: Interstitial load request sent")


func _on_interstitial_ad_loaded(ad: InterstitialAd) -> void:
	print("AdMobAdsService: Interstitial ad loaded!")
	_interstitial_ad = ad

	# Set up fullscreen content callback
	var content_callback := FullScreenContentCallback.new()
	content_callback.on_ad_clicked = func(): print("AdMobAdsService: Interstitial clicked")
	content_callback.on_ad_impression = func(): print("AdMobAdsService: Interstitial impression")
	content_callback.on_ad_showed_full_screen_content = func(): print("AdMobAdsService: Interstitial shown")
	content_callback.on_ad_dismissed_full_screen_content = _on_interstitial_dismissed
	content_callback.on_ad_failed_to_show_full_screen_content = func(error: AdError):
		print("AdMobAdsService: Interstitial failed to show: ", error.message if error else "Unknown")
		if _interstitial_close_callback.is_valid():
			_interstitial_close_callback.call()

	_interstitial_ad.full_screen_content_callback = content_callback
	_interstitial_ready = true
	interstitial_loaded.emit()


func _on_interstitial_ad_failed_to_load(error: LoadAdError) -> void:
	var error_msg := "Interstitial failed to load: " + str(error.message) if error else "Unknown error"
	print("AdMobAdsService: ", error_msg)
	_interstitial_ready = false
	interstitial_failed.emit(error_msg)


func _on_interstitial_dismissed() -> void:
	print("AdMobAdsService: Interstitial dismissed")
	_interstitial_ready = false

	# Destroy the ad
	if _interstitial_ad != null:
		_interstitial_ad.destroy()
		_interstitial_ad = null

	# Call the close callback
	if _interstitial_close_callback.is_valid():
		_interstitial_close_callback.call()

	interstitial_closed.emit()

	# Preload next interstitial
	load_interstitial()


## Checks if interstitial ad is ready
func is_interstitial_ready() -> bool:
	return _interstitial_ready


## Shows an interstitial ad
func show_interstitial(on_close: Callable) -> void:
	print("AdMobAdsService: show_interstitial() called, ready=", _interstitial_ready)

	if not _is_initialized:
		print("AdMobAdsService: Not initialized, calling callback directly")
		on_close.call()
		return

	if not _interstitial_ready or _interstitial_ad == null:
		print("AdMobAdsService: Interstitial not ready, calling callback directly")
		interstitial_failed.emit("Interstitial ad not ready")
		on_close.call()
		return

	_interstitial_close_callback = on_close
	_interstitial_ad.show()
	print("AdMobAdsService: Showing interstitial ad")


## Loads a rewarded ad
func load_rewarded(ad_unit_key: String = "rewarded") -> void:
	print("AdMobAdsService: load_rewarded() called")

	if not _is_initialized:
		print("AdMobAdsService: Cannot load rewarded - not initialized!")
		rewarded_failed.emit("AdMob not initialized")
		return

	var ad_unit_id: String = str(_config.get("rewarded_ad_unit_id", ""))
	if ad_unit_id.is_empty():
		ad_unit_id = "ca-app-pub-3940256099942544/5224354917"  # Google test rewarded
		print("AdMobAdsService: Using test rewarded ad unit ID")

	_rewarded_ready = false

	# Create load callback
	var load_callback := RewardedAdLoadCallback.new()
	load_callback.on_ad_loaded = _on_rewarded_ad_loaded
	load_callback.on_ad_failed_to_load = _on_rewarded_ad_failed_to_load

	# Load the ad
	RewardedAdLoader.new().load(ad_unit_id, AdRequest.new(), load_callback)
	print("AdMobAdsService: Rewarded ad load request sent")


func _on_rewarded_ad_loaded(ad: RewardedAd) -> void:
	print("AdMobAdsService: Rewarded ad loaded!")
	_rewarded_ad = ad

	# Set up fullscreen content callback
	var content_callback := FullScreenContentCallback.new()
	content_callback.on_ad_clicked = func(): print("AdMobAdsService: Rewarded ad clicked")
	content_callback.on_ad_impression = func(): print("AdMobAdsService: Rewarded ad impression")
	content_callback.on_ad_showed_full_screen_content = func(): print("AdMobAdsService: Rewarded ad shown")
	content_callback.on_ad_dismissed_full_screen_content = _on_rewarded_dismissed
	content_callback.on_ad_failed_to_show_full_screen_content = func(error: AdError):
		print("AdMobAdsService: Rewarded ad failed to show: ", error.message if error else "Unknown")
		if _fail_callback.is_valid():
			_fail_callback.call()

	_rewarded_ad.full_screen_content_callback = content_callback
	_rewarded_ready = true
	rewarded_loaded.emit()


func _on_rewarded_ad_failed_to_load(error: LoadAdError) -> void:
	var error_msg := "Rewarded ad failed to load: " + str(error.message) if error else "Unknown error"
	print("AdMobAdsService: ", error_msg)
	_rewarded_ready = false
	rewarded_failed.emit(error_msg)


func _on_rewarded_dismissed() -> void:
	print("AdMobAdsService: Rewarded ad dismissed")
	_rewarded_ready = false

	# Destroy the ad
	if _rewarded_ad != null:
		_rewarded_ad.destroy()
		_rewarded_ad = null

	rewarded_closed.emit()

	# Preload next rewarded ad
	load_rewarded()


func _on_user_earned_reward(reward: RewardedItem) -> void:
	print("AdMobAdsService: User earned reward - Type: %s, Amount: %d" % [reward.type, reward.amount])
	if _reward_callback.is_valid():
		_reward_callback.call()
	rewarded_earned.emit()


## Checks if rewarded ad is ready
func is_rewarded_ready() -> bool:
	return _rewarded_ready


## Shows a rewarded ad
func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	print("AdMobAdsService: show_rewarded() called, ready=", _rewarded_ready)

	if not _is_initialized:
		print("AdMobAdsService: Not initialized")
		on_fail.call()
		return

	if not _rewarded_ready or _rewarded_ad == null:
		print("AdMobAdsService: Rewarded ad not ready")
		rewarded_failed.emit("Rewarded ad not ready")
		on_fail.call()
		return

	_reward_callback = on_reward
	_fail_callback = on_fail

	# Create reward listener
	var reward_listener := OnUserEarnedRewardListener.new()
	reward_listener.on_user_earned_reward = _on_user_earned_reward

	_rewarded_ad.show(reward_listener)
	print("AdMobAdsService: Showing rewarded ad")


## Requests consent if required (GDPR/UMP)
func request_consent_if_required(on_done: Callable) -> void:
	print("AdMobAdsService: request_consent_if_required() called")
	# For now, just proceed - UMP can be implemented later
	consent_completed.emit(true)
	if on_done.is_valid():
		on_done.call()


## Returns if service is supported
func is_supported() -> bool:
	return is_plugin_available()


## Returns if service is initialized
func is_initialized() -> bool:
	return _is_initialized
