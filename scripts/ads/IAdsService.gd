## IAdsService.gd
## Abstract base class defining the ads service interface.
## All ads service implementations must extend this class.
class_name IAdsService
extends RefCounted

# Signals for ad events
signal banner_loaded
signal banner_failed(error: String)
signal rewarded_loaded
signal rewarded_failed(error: String)
signal rewarded_earned
signal rewarded_closed
signal consent_completed(granted: bool)

# Abstract methods - override in implementations

## Initializes the ads service
func initialize() -> void:
	push_error("IAdsService.initialize() must be overridden")


## Shows a banner ad at the specified position
func show_banner(position: String = "bottom") -> void:
	push_error("IAdsService.show_banner() must be overridden")


## Hides the currently displayed banner
func hide_banner() -> void:
	push_error("IAdsService.hide_banner() must be overridden")


## Loads a rewarded ad
func load_rewarded(ad_unit_key: String = "rewarded") -> void:
	push_error("IAdsService.load_rewarded() must be overridden")


## Checks if a rewarded ad is ready to show
func is_rewarded_ready() -> bool:
	push_error("IAdsService.is_rewarded_ready() must be overridden")
	return false


## Shows a rewarded ad with callbacks
func show_rewarded(on_reward: Callable, on_fail: Callable) -> void:
	push_error("IAdsService.show_rewarded() must be overridden")


## Requests user consent if required (GDPR/UMP)
func request_consent_if_required(on_done: Callable) -> void:
	push_error("IAdsService.request_consent_if_required() must be overridden")


## Returns true if ads are supported on this platform
func is_supported() -> bool:
	return false


## Returns true if the service is initialized
func is_initialized() -> bool:
	return false
