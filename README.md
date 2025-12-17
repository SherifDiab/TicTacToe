# Tic-Tac-Toe (Godot 4.x)

A polished Tic-Tac-Toe game with Player vs Engine mode and AdMob monetization on Android.

## Features

- **Player vs Engine (PvE)** - Play against the AI
- **Three Difficulty Levels**:
  - **Easy**: Mostly random moves
  - **Medium**: Limited-depth minimax with randomness
  - **Hard**: Full minimax + alpha-beta pruning (unbeatable)
- **Choose Your Symbol** - Play as X (first) or O (second)
- **Statistics Tracking** - Wins, losses, draws, streaks
- **AdMob Integration** - Banner and Rewarded ads on Android
- **Cross-Platform** - Runs on Desktop (without ads) and Android (with ads)

---

## Project Overview

### Directory Structure

```
TicTacToe/
├── project.godot              # Project configuration
├── icon.svg                   # App icon
├── README.md                  # This file
├── config/
│   └── ads_config.gd          # AdMob configuration
├── scenes/
│   ├── MainMenu.tscn          # Main menu scene
│   ├── Game.tscn              # Game board scene
│   └── GameOverPanel.tscn     # Game over popup
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd     # Global game state manager
│   │   └── AdsManager.gd      # Global ads manager
│   ├── game/
│   │   ├── Board.gd           # Board state and logic
│   │   └── GameController.gd  # Game state machine
│   ├── ai/
│   │   └── TicTacToeAI.gd     # AI with minimax
│   ├── persistence/
│   │   └── StatsStore.gd      # Statistics persistence
│   ├── ads/
│   │   ├── IAdsService.gd     # Ads interface
│   │   ├── AdMobAdsService.gd # Android AdMob implementation
│   │   ├── NullAdsService.gd  # Desktop fallback
│   │   └── AdsServiceFactory.gd # Factory for ads service
│   └── ui/
│       ├── MainMenu.gd        # Main menu controller
│       ├── Game.gd            # Game scene controller
│       └── GameOverPanel.gd   # Game over panel controller
└── android/
    └── build/
        └── AndroidManifest.xml # Android manifest (created during export setup)
```

---

## How to Open the Project

1. **Download and Install Godot 4.x**
   - Download from: https://godotengine.org/download
   - Use the standard version (not .NET)

2. **Open the Project**
   - Launch Godot
   - Click "Import" in the Project Manager
   - Navigate to the project folder and select `project.godot`
   - Click "Import & Edit"

3. **Run on Desktop**
   - Press F5 or click the Play button
   - The game runs without ads on desktop

---

## How to Install/Enable the AdMob Plugin

### Step 1: Download the Plugin

1. Go to: https://github.com/poing-studios/godot-admob-plugin/releases
2. Download the latest release for Godot 4.x
3. The download includes:
   - `addons/` folder (editor plugin)
   - `android/plugins/` folder (Android plugin)

### Step 2: Install the Plugin

1. **Copy the `addons` folder** to your project root:
   ```
   TicTacToe/addons/admob/
   ```

2. **Copy the Android plugin files** to your project:
   ```
   TicTacToe/android/plugins/poing-godot-admob-android-release.aar
   TicTacToe/android/plugins/poing-godot-admob-android.gdap
   ```

### Step 3: Enable the Plugin in Godot

1. Open the project in Godot
2. Go to **Project → Project Settings → Plugins**
3. Find "AdMob" in the list and check "Enable"

### Step 4: Configure Android Build

1. Go to **Project → Project Settings → General → Android**
2. Set up your custom build:
   - Go to **Project → Export**
   - Add Android preset if not exists
   - Enable "Use Custom Build"
   - Click "Install Android Build Template"

### Step 5: Enable the Android Plugin

1. In the Export dialog, under "Options":
2. Check the "Poing Godot Admob Android" plugin

---

## How to Configure AdMob IDs

### Step 1: Get Your AdMob IDs

1. Create an AdMob account at https://admob.google.com
2. Create an app for Android
3. Create ad units:
   - Banner ad unit
   - Rewarded ad unit
4. Note down your:
   - **App ID**: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
   - **Banner Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ`
   - **Rewarded Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/WWWWWWWWWW`

### Step 2: Update the Configuration File

Edit `config/ads_config.gd`:

```gdscript
## Replace these TEST IDs with your REAL IDs for production
const ADMOB_APP_ID: String = "ca-app-pub-YOUR_APP_ID"
const BANNER_AD_UNIT_ID: String = "ca-app-pub-YOUR_BANNER_ID"
const REWARDED_AD_UNIT_ID: String = "ca-app-pub-YOUR_REWARDED_ID"
```

### Step 3: Update AndroidManifest.xml

After installing the Android build template, edit:
`android/build/AndroidManifest.xml`

Add inside the `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_APP_ID"/>
```

### Test IDs (For Development)

Use these during development to avoid policy violations:

| Type | Test ID |
|------|---------|
| App ID | `ca-app-pub-3940256099942544~3347511713` |
| Banner | `ca-app-pub-3940256099942544/6300978111` |
| Rewarded | `ca-app-pub-3940256099942544/5224354917` |

---

## How to Run on Android

### Prerequisites

1. **Android SDK** - Install via Android Studio or standalone
2. **Debug Keystore** - Generated automatically or use your own
3. **USB Debugging** - Enable on your Android device

### Steps

1. **Configure Export Settings**
   - Go to **Editor → Editor Settings → Export → Android**
   - Set paths for:
     - Android SDK Path
     - Debug Keystore Path
     - Debug Keystore User/Password

2. **Connect Your Device**
   - Enable USB debugging on your Android device
   - Connect via USB
   - Accept the debugging prompt on device

3. **Run**
   - Click the Android icon in the top-right toolbar
   - Or go to **Project → Export → Android → Run**

---

## How to Export to Android

### Step 1: Create Export Preset

1. Go to **Project → Export**
2. Click "Add..." and select "Android"

### Step 2: Configure the Preset

**Basic Settings:**
- Unique Name: `com.yourcompany.tictactoe`
- Name: `Tic-Tac-Toe`
- Version Code: `1`
- Version Name: `1.0`

**Custom Build:**
- Enable "Use Custom Build"
- Check the AdMob plugin in the plugins list

**Permissions:**
- INTERNET (required for ads)
- ACCESS_NETWORK_STATE (optional, for ad targeting)

### Step 3: Configure Signing

For release builds, you need a release keystore:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore release.keystore -alias your_alias -keyalg RSA -keysize 2048 -validity 10000
   ```

2. In Export Settings:
   - Release → Keystore: path to your keystore
   - Release → Keystore User: your alias
   - Release → Keystore Password: your password

### Step 4: Export

1. Click "Export Project"
2. Choose location and filename
3. Select APK or AAB (Android App Bundle)
4. For Google Play, use AAB format

---

## Ads Behavior Summary

| Screen | Banner | Rewarded |
|--------|--------|----------|
| Main Menu | Shown (bottom) | - |
| Gameplay | Hidden | - |
| Game Over | Shown (bottom) | "Watch Ad for Undo" button |

### Rewarded Ad Flow

1. On game over, "Watch Ad for Undo" button appears
2. Player watches a rewarded ad
3. On completion, the last move is undone
4. Limited to 1 use per match

### Consent (GDPR/UMP)

The plugin supports Google's User Messaging Platform (UMP) for GDPR consent.
The `AdsManager` calls `request_consent_if_required()` on initialization.

---

## Architecture Notes

### Ads Abstraction

The ads system uses an abstraction layer:

- `IAdsService` - Interface defining all ad methods
- `AdMobAdsService` - Android implementation using Poing plugin
- `NullAdsService` - Desktop fallback (logs actions, simulates for testing)
- `AdsServiceFactory` - Creates the appropriate service based on platform

This allows the game to run on any platform without errors.

### Game Controller

The `GameController` manages:
- Game state machine (MENU → PLAYING → GAME_OVER)
- Turn logic
- AI integration
- Undo functionality for rewarded ads

### AI Implementation

- **Easy**: Random moves with occasional win-taking
- **Medium**: Depth-limited minimax (depth 3) with randomness
- **Hard**: Full minimax with alpha-beta pruning - unbeatable

---

## Troubleshooting

### Ads Not Loading

1. Check internet connection
2. Verify AdMob IDs are correct
3. Check AndroidManifest.xml has the App ID
4. Enable the AdMob plugin in export settings
5. Test with test IDs first

### Plugin Not Found

1. Ensure `android/plugins/` folder contains the .aar and .gdap files
2. Check the plugin is enabled in Export settings
3. Rebuild the custom Android template

### App Crashes on Launch

1. Check logcat for errors: `adb logcat | grep godot`
2. Verify AndroidManifest.xml is valid
3. Ensure all plugin files are in place

---

## References

- [Godot Android Plugins](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html)
- [Installing Plugins in Godot](https://docs.godotengine.org/en/4.4/tutorials/plugins/editor/installing_plugins.html)
- [Poing Studios AdMob Plugin](https://poingstudios.github.io/godot-admob-plugin/)
- [Poing Rewarded Ads](https://poingstudios.github.io/godot-admob-plugin/ad_formats/rewarded/)
- [Poing UMP/Consent](https://poingstudios.github.io/godot-admob-plugin/privacy/user_messaging_tools/get_started/)

---

## License

This project is provided as-is for educational purposes.
