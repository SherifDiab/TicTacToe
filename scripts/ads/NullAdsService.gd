## NullAdsService.gd
## Desktop/fallback implementation that does nothing but logs actions.
## Used when ads are not supported (non-Android platforms) or when
## AdMob plugin is missing on mobile.
class_name NullAdsService
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

var _initialized: bool = false
var _banner_visible: bool = false
var _interstitial_ready: bool = false
var _rewarded_ready: bool = false
var _is_mobile_fallback: bool = false

# For testing on desktop: simulate ads being ready after load
var _simulate_ads: bool = true


func _init() -> void:
	# Check if we're on mobile but using NullAdsService (plugin missing)
	_is_mobile_fallback = OS.has_feature("android") or OS.has_feature("ios")
	if _is_mobile_fallback:
		push_error("======================================================")
		push_error("NullAdsService: Running on mobile WITHOUT AdMob plugin!")
		push_error("NO ADS WILL BE DISPLAYED!")
		push_error("PoingGodotAdMob singleton not found.")
		push_error("Make sure 'AdMob' plugin is enabled in Export -> Plugins")
		push_error("======================================================")


## Initializes the null service (just logs)
func initialize() -> void:
	if _is_mobile_fallback:
		print("[NullAdsService] WARNING: Mobile platform but AdMob plugin missing!")
		print("[NullAdsService] Ads will be simulated but NOT shown on screen")
	else:
		print("[NullAdsService] Desktop mode - ads simulation enabled")
	_initialized = true


## Shows banner (just logs)
func show_banner(position: String = "bottom") -> void:
	print("[NullAdsService] show_banner('%s') called" % position)
	_banner_visible = true
	banner_loaded.emit()


## Hides banner (just logs)
func hide_banner() -> void:
	print("[NullAdsService] hide_banner() called")
	_banner_visible = false


## Loads interstitial ad (simulates loading for testing)
func load_interstitial(ad_unit_key: String = "interstitial") -> void:
	print("[NullAdsService] load_interstitial('%s') called" % ad_unit_key)

	if _simulate_ads:
		_interstitial_ready = true
		interstitial_loaded.emit()
		print("[NullAdsService] Simulated interstitial ad loaded")
	else:
		interstitial_failed.emit("Ads not available on this platform")


## Checks if interstitial is ready
func is_interstitial_ready() -> bool:
	return _interstitial_ready


## Shows interstitial ad (simulates for testing)
func show_interstitial(on_close: Callable) -> void:
	print("[NullAdsService] show_interstitial() called")

	if _simulate_ads and _interstitial_ready:
		print("[NullAdsService] Simulating interstitial shown and closed")
		_interstitial_ready = false
		interstitial_closed.emit()
		if on_close.is_valid():
			on_close.call()
		# Reload for next use
		load_interstitial()
	else:
		print("[NullAdsService] No interstitial ad available, proceeding anyway")
		interstitial_failed.emit("No ad available")
		if on_close.is_valid():
			on_close.call()


## Loads rewarded ad (simulates loading for testing)
func load_rewarded(ad_unit_key: String = "rewarded") -> void:
	print("[NullAdsService] load_rewarded('%s') called" % ad_unit_key)

	if _simulate_ads:
		# Simulate async loading with a delay
		_rewarded_ready = true
		rewarded_loaded.emit()
		print("[NullAdsService] Simulated rewarded ad loaded")
	else:
		rewarded_failed.emit("Ads not available on this platform")


## Checks if rewarded is ready
func is_rewarded_ready() -> bool:
	print("[NullAdsService] is_rewarded_ready() = %s" % str(_rewarded_ready))
	return _rewarded_ready


## Shows rewarded ad (simulates for testing)
func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	print("[NullAdsService] show_rewarded() called")

	if _simulate_ads and _rewarded_ready:
		# Simulate watching an ad - immediately grant reward
		print("[NullAdsService] Simulating reward earned")
		_rewarded_ready = false
		rewarded_earned.emit()
		if on_reward.is_valid():
			on_reward.call()
		rewarded_closed.emit()
		# Reload for next use
		load_rewarded()
	else:
		print("[NullAdsService] No rewarded ad available")
		rewarded_failed.emit("No ad available")
		if on_fail.is_valid():
			on_fail.call()


## Requests consent (no-op on desktop)
func request_consent_if_required(on_done: Callable) -> void:
	print("[NullAdsService] request_consent_if_required() called (no-op)")
	consent_completed.emit(true)
	if on_done.is_valid():
		on_done.call()


## Returns if supported (always false for null service)
func is_supported() -> bool:
	return false


## Returns if initialized
func is_initialized() -> bool:
	return _initialized


## Enables/disables ad simulation for desktop testing
func set_simulate_ads(simulate: bool) -> void:
	_simulate_ads = simulate
	print("[NullAdsService] Ad simulation %s" % ("enabled" if simulate else "disabled"))
