## AdsServiceFactory.gd
## Factory for creating the appropriate ads service based on platform.
class_name AdsServiceFactory
extends RefCounted


## Creates and returns the appropriate ads service for the current platform
static func create_ads_service(config: Dictionary = {}) -> IAdsService:
	# Check if running on Android
	if OS.has_feature("android"):
		print("[AdsServiceFactory] Android detected, creating AdMobAdsService")
		return AdMobAdsService.new(config)

	# Check if running on iOS (for future support)
	if OS.has_feature("ios"):
		print("[AdsServiceFactory] iOS detected, creating AdMobAdsService")
		return AdMobAdsService.new(config)

	# Desktop or other platforms: use null service
	print("[AdsServiceFactory] Desktop/other platform detected, creating NullAdsService")
	return NullAdsService.new()


## Checks if ads are supported on the current platform
static func is_ads_supported() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios")


## Returns the current platform name
static func get_platform_name() -> String:
	if OS.has_feature("android"):
		return "Android"
	elif OS.has_feature("ios"):
		return "iOS"
	elif OS.has_feature("windows"):
		return "Windows"
	elif OS.has_feature("macos"):
		return "macOS"
	elif OS.has_feature("linux"):
		return "Linux"
	elif OS.has_feature("web"):
		return "Web"
	return "Unknown"
