# Square Home — Flutter Launcher

A Windows Phone-style Metro launcher for Android, written in Flutter.

## Features

- **Metro-style tile grid** — small (1×1), wide (2×1), tall (1×2), large (2×2), extra-large (4×2) tiles
- **Flow-packing layout** — tiles auto-pack left-to-right, top-to-bottom, no gaps
- **Real device apps** — reads your installed apps via `installed_apps` (Android only)
- **Folders** — group apps into folder tiles with a mini 2×2 icon grid
- **Edit mode** — long-press any tile to enter edit mode; drag tiles to reorder, tap for resize/color/remove options
- **Lock screen** — swipe-up to reveal PIN keypad (default PIN: `1234`); shows live clock + date
- **Custom wallpapers** — pick a photo from your gallery for the home screen or lock screen
- **Accent colours** — 10 accent colours applied to all tiles
- **Settings** — grid columns (4 or 6), accent, wallpapers, labels toggle, animation toggle, double-tap lock, swipe-up drawer
- **Persistent state** — all tiles and settings are saved to `SharedPreferences`

## Getting started

### Prerequisites

- Flutter 3.16+ (stable)
- Android SDK 21+

### Run

```bash
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Set as default launcher

After installing, press the Android Home button → choose "Square Home" → set as default.

## Project structure

```
lib/
  main.dart                   Entry point + MaterialApp
  models/
    tile_model.dart           TileSize, HomeItem, AppTileItem, FolderTileItem
    launcher_settings.dart    LauncherSettings, AccentOption, WallpaperOption
  providers/
    launcher_provider.dart    State management + SharedPreferences persistence
  screens/
    home_screen.dart          Main launcher screen
    lock_screen.dart          Lock screen with clock + PIN keypad
  widgets/
    home_grid.dart            Metro grid (flow-packer + Stack/Positioned)
    app_tile.dart             Single app tile widget
    folder_tile.dart          Folder tile widget
    app_drawer_sheet.dart     Swipe-up app list bottom sheet
    settings_sheet.dart       Settings bottom sheet
    tile_options_sheet.dart   Tile resize/colour/remove sheet
  data/
    app_catalog.dart          Built-in fallback app list + icon codes
  utils/
    grid_packer.dart          Greedy flow-packing algorithm
android/
  app/src/main/
    AndroidManifest.xml       HOME intent filter (makes this a launcher)
    kotlin/com/squarehome/
      MainActivity.kt
    res/values/styles.xml
```

## Default PIN

The lock screen PIN is `1234`. To change it, edit `_pin` in `lib/screens/lock_screen.dart`.

## Permissions

| Permission | Why |
|---|---|
| `QUERY_ALL_PACKAGES` | List installed apps in the drawer |
| `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` | Pick wallpaper photos from gallery |
