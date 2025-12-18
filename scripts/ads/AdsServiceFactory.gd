## AdsServiceFactory.gd
## Factory for creating the appropriate ads service based on platform.
class_name AdsServiceFactory
extends RefCounted


## Creates and returns the appropriate ads service for the current platform
static func create_ads_service(config: Dictionary = {}):
	print("[AdsServiceFactory] Platform: ", OS.get_name())
	print("[AdsServiceFactory] Android feature: ", OS.has_feature("android"))
	print("[AdsServiceFactory] iOS feature: ", OS.has_feature("ios"))

	# Check for new Poing AdMob plugin (uses PoingGodotAdMob singleton)
	var has_poing_admob: bool = Engine.has_singleton("PoingGodotAdMob")
	print("[AdsServiceFactory] PoingGodotAdMob singleton available: ", has_poing_admob)

	# Check if running on Android
	if OS.has_feature("android"):
		# Check if AdMob plugin is available
		if has_poing_admob:
			print("[AdsServiceFactory] Android + Poing AdMob plugin found, creating AdMobAdsService")
			return AdMobAdsService.new(config)
		else:
			push_error("[AdsServiceFactory] Android detected but Poing AdMob plugin NOT INSTALLED!")
			push_error("[AdsServiceFactory] Make sure 'AdMob' is enabled in Export -> Plugins")
			print("[AdsServiceFactory] Falling back to NullAdsService (no ads will show)")
			return NullAdsService.new()

	# Check if running on iOS (for future support)
	if OS.has_feature("ios"):
		if has_poing_admob:
			print("[AdsServiceFactory] iOS + Poing AdMob plugin found, creating AdMobAdsService")
			return AdMobAdsService.new(config)
		else:
			push_error("[AdsServiceFactory] iOS detected but Poing AdMob plugin NOT INSTALLED!")
			print("[AdsServiceFactory] Falling back to NullAdsService (no ads will show)")
			return NullAdsService.new()

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
