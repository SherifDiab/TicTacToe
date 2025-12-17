## NullAdsService.gd
## Desktop/fallback implementation that does nothing but logs actions.
## Used when ads are not supported (non-Android platforms).
class_name NullAdsService
extends IAdsService

var _initialized: bool = false
var _banner_visible: bool = false
var _rewarded_ready: bool = false

# For testing on desktop: simulate rewarded being ready after load
var _simulate_ads: bool = true


func _init() -> void:
	pass


## Initializes the null service (just logs)
func initialize() -> void:
	print("[NullAdsService] Initialize called (ads disabled on this platform)")
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
