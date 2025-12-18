# AdMob Setup Guide for TicTacToe

This guide explains how to set up AdMob ads for the TicTacToe game on Android.

## Step 1: Download the Godot AdMob Plugin

Download the **Poing Studios Godot AdMob Plugin** for your Godot version:

**For Godot 4.x:**
- Go to: https://github.com/poing-studios/godot-admob-android/releases
- Download the latest release for Godot 4.x (e.g., `godot-admob-android-v4.x.x.zip`)

## Step 2: Install the Plugin

1. Extract the downloaded ZIP file
2. Copy the `addons/admob` folder to your project's `addons/` folder:
   ```
   TicTacToe/
   └── addons/
       └── admob/           <- Copy this folder here
   ```

3. Copy the Android plugin files to `android/plugins/`:
   ```
   TicTacToe/
   └── android/
       └── plugins/
           ├── GodotAdMob.gdap     <- Plugin config file
           └── GodotAdMob.release.aar  <- Plugin library
   ```

## Step 3: Configure Android Export

1. Open Godot Editor
2. Go to **Project → Export**
3. Select the **Android** preset
4. Enable **"Use Custom Build"** (under Custom Build section)
5. Click **"Install Android Build Template"** if not already done
6. Under **Plugins**, enable **"Godot AdMob"**

## Step 4: Configure AndroidManifest.xml

After installing the build template, edit `android/build/AndroidManifest.xml`:

Add this inside the `<application>` tag:

```xml
<!-- AdMob App ID - Use test ID for development -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**Important:** Replace with your real AdMob App ID for production!

## Step 5: Configure Ad Unit IDs

Edit `config/ads_config.gd` to set your ad unit IDs:

```gdscript
# For testing (current values)
const BANNER_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6300978111"
const INTERSTITIAL_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1033173712"
const REWARDED_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"

# For production (replace with your IDs)
# const BANNER_AD_UNIT_ID: String = "ca-app-pub-XXXXXXXX/YYYYYYYYY"
# const INTERSTITIAL_AD_UNIT_ID: String = "ca-app-pub-XXXXXXXX/YYYYYYYYY"
# const REWARDED_AD_UNIT_ID: String = "ca-app-pub-XXXXXXXX/YYYYYYYYY"
```

## Step 6: Build and Test

1. Connect your Android device via USB
2. Enable USB debugging on the device
3. In Godot, click the Android icon in the top-right corner to deploy
4. Check the logs for "AdMob plugin FOUND successfully!" message

## Troubleshooting

### "AdMob plugin NOT FOUND" Error

If you see this error in the logs:
1. Make sure the plugin files are in the correct locations
2. Verify "Godot AdMob" is enabled in Export → Android → Plugins
3. Try "Clean Build" before exporting

### Ads Not Showing

1. Check if you have internet connectivity on the device
2. Test ads may not always fill - wait a few seconds
3. Check logcat for AdMob-related errors:
   ```bash
   adb logcat | grep -i admob
   ```

### Common Logcat Errors

- **"Missing AdMob App ID"**: Add the meta-data to AndroidManifest.xml
- **"Invalid ad unit ID"**: Check your ad unit IDs in ads_config.gd
- **"No fill"**: Test ads may not always be available, try again later

## Test Ad Unit IDs (for Development)

These test IDs always show test ads:

| Ad Type      | Test Ad Unit ID                          |
|--------------|------------------------------------------|
| Banner       | ca-app-pub-3940256099942544/6300978111   |
| Interstitial | ca-app-pub-3940256099942544/1033173712   |
| Rewarded     | ca-app-pub-3940256099942544/5224354917   |
| App ID       | ca-app-pub-3940256099942544~3347511713   |

## Production Checklist

Before releasing to production:

- [ ] Create AdMob account at https://admob.google.com
- [ ] Register your app in AdMob console
- [ ] Create ad units for Banner, Interstitial, and Rewarded
- [ ] Replace test App ID with real App ID in AndroidManifest.xml
- [ ] Replace test ad unit IDs with real IDs in ads_config.gd
- [ ] Set `is_real = true` in AdMobAdsService.gd initialization
- [ ] Test thoroughly before release
