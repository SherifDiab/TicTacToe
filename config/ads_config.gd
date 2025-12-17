## ads_config.gd
## Configuration file for AdMob ads.
##
## IMPORTANT: Replace placeholder IDs with your actual AdMob IDs for production!
##
## Test IDs (safe for development):
##   Banner: ca-app-pub-3940256099942544/6300978111
##   Rewarded: ca-app-pub-3940256099942544/5224354917
##   App ID: ca-app-pub-3940256099942544~3347511713
##
## Production IDs:
##   1. Create an AdMob account at https://admob.google.com
##   2. Create an app and ad units in your AdMob dashboard
##   3. Replace the IDs below with your real IDs
##   4. Update AndroidManifest.xml with your real App ID
class_name AdsConfig
extends RefCounted

# =============================================================================
# ADMOB CONFIGURATION
# =============================================================================

## AdMob Application ID
## This is also configured in android/build/AndroidManifest.xml
## MUST match the value in AndroidManifest for Android builds
const ADMOB_APP_ID: String = "ca-app-pub-3940256099942544~3347511713"  # TEST ID

## Banner Ad Unit ID
## Standard banner size: 320x50 (BANNER)
const BANNER_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6300978111"  # TEST ID

## Rewarded Video Ad Unit ID
const REWARDED_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"  # TEST ID


# =============================================================================
# AD BEHAVIOR SETTINGS
# =============================================================================

## Show banner on main menu
const SHOW_BANNER_ON_MENU: bool = true

## Show banner during gameplay
const SHOW_BANNER_DURING_GAME: bool = false

## Show banner on game over screen
const SHOW_BANNER_ON_GAME_OVER: bool = true

## Banner position ("top" or "bottom")
const BANNER_POSITION: String = "bottom"

## Preload rewarded ads
const PRELOAD_REWARDED: bool = true


# =============================================================================
# HELPER METHODS
# =============================================================================

## Returns configuration as a dictionary for ads service initialization
static func get_config() -> Dictionary:
	return {
		"admob_app_id": ADMOB_APP_ID,
		"banner_ad_unit_id": BANNER_AD_UNIT_ID,
		"rewarded_ad_unit_id": REWARDED_AD_UNIT_ID,
		"banner_position": BANNER_POSITION,
		"show_banner_on_menu": SHOW_BANNER_ON_MENU,
		"show_banner_during_game": SHOW_BANNER_DURING_GAME,
		"show_banner_on_game_over": SHOW_BANNER_ON_GAME_OVER,
		"preload_rewarded": PRELOAD_REWARDED
	}


## Checks if using test IDs
static func is_using_test_ids() -> bool:
	return ADMOB_APP_ID.contains("3940256099942544")


## Prints configuration status
static func print_config_status() -> void:
	print("=== AdMob Configuration ===")
	print("App ID: ", ADMOB_APP_ID)
	print("Banner ID: ", BANNER_AD_UNIT_ID)
	print("Rewarded ID: ", REWARDED_AD_UNIT_ID)
	print("Using Test IDs: ", is_using_test_ids())
	print("===========================")
