import 'dart:convert';

const kAccentOptions = [
  AccentOption(id: 'amber', label: 'Amber', hex: 0xFFFFC107),
  AccentOption(id: 'blue', label: 'Blue', hex: 0xFF2196F3),
  AccentOption(id: 'cyan', label: 'Cyan', hex: 0xFF00BCD4),
  AccentOption(id: 'green', label: 'Green', hex: 0xFF4CAF50),
  AccentOption(id: 'lime', label: 'Lime', hex: 0xFFCDDC39),
  AccentOption(id: 'orange', label: 'Orange', hex: 0xFFFF9800),
  AccentOption(id: 'pink', label: 'Pink', hex: 0xFFE91E63),
  AccentOption(id: 'purple', label: 'Purple', hex: 0xFF9C27B0),
  AccentOption(id: 'red', label: 'Red', hex: 0xFFF44336),
  AccentOption(id: 'teal', label: 'Teal', hex: 0xFF009688),
];

const kWallpaperOptions = [
  WallpaperOption(id: 'midnight', label: 'Midnight', primaryHex: 0xFF0C0D10, secondaryHex: 0xFF161820),
  WallpaperOption(id: 'slate', label: 'Slate', primaryHex: 0xFF1A1D27, secondaryHex: 0xFF252836),
  WallpaperOption(id: 'dusk', label: 'Dusk', primaryHex: 0xFF1A0A2E, secondaryHex: 0xFF2D1B4E),
  WallpaperOption(id: 'forest', label: 'Forest', primaryHex: 0xFF0A1A0D, secondaryHex: 0xFF142A18),
  WallpaperOption(id: 'ocean', label: 'Ocean', primaryHex: 0xFF0A1628, secondaryHex: 0xFF0D2040),
  WallpaperOption(id: 'ash', label: 'Ash', primaryHex: 0xFF1C1C1E, secondaryHex: 0xFF2C2C2E),
];

class AccentOption {
  final String id;
  final String label;
  final int hex;

  const AccentOption({required this.id, required this.label, required this.hex});
}

class WallpaperOption {
  final String id;
  final String label;
  final int primaryHex;
  final int secondaryHex;

  const WallpaperOption({
    required this.id,
    required this.label,
    required this.primaryHex,
    required this.secondaryHex,
  });
}

class LauncherSettings {
  final int columns;
  final String accentId;
  final String wallpaperId;
  final String lockWallpaperId;
  final String? customWallpaperPath;
  final String? customLockWallpaperPath;
  final bool doubleTapLock;
  final bool showLabels;
  final bool tileAnimations;
  final bool swipeUpDrawer;

  const LauncherSettings({
    this.columns = 4,
    this.accentId = 'amber',
    this.wallpaperId = 'midnight',
    this.lockWallpaperId = 'midnight',
    this.customWallpaperPath,
    this.customLockWallpaperPath,
    this.doubleTapLock = false,
    this.showLabels = true,
    this.tileAnimations = true,
    this.swipeUpDrawer = true,
  });

  AccentOption get accent =>
      kAccentOptions.firstWhere((a) => a.id == accentId, orElse: () => kAccentOptions.first);

  WallpaperOption get wallpaper =>
      kWallpaperOptions.firstWhere((w) => w.id == wallpaperId, orElse: () => kWallpaperOptions.first);

  WallpaperOption get lockWallpaper =>
      kWallpaperOptions.firstWhere((w) => w.id == lockWallpaperId, orElse: () => kWallpaperOptions.first);

  LauncherSettings copyWith({
    int? columns,
    String? accentId,
    String? wallpaperId,
    String? lockWallpaperId,
    Object? customWallpaperPath = _sentinel,
    Object? customLockWallpaperPath = _sentinel,
    bool? doubleTapLock,
    bool? showLabels,
    bool? tileAnimations,
    bool? swipeUpDrawer,
  }) =>
      LauncherSettings(
        columns: columns ?? this.columns,
        accentId: accentId ?? this.accentId,
        wallpaperId: wallpaperId ?? this.wallpaperId,
        lockWallpaperId: lockWallpaperId ?? this.lockWallpaperId,
        customWallpaperPath: customWallpaperPath == _sentinel
            ? this.customWallpaperPath
            : customWallpaperPath as String?,
        customLockWallpaperPath: customLockWallpaperPath == _sentinel
            ? this.customLockWallpaperPath
            : customLockWallpaperPath as String?,
        doubleTapLock: doubleTapLock ?? this.doubleTapLock,
        showLabels: showLabels ?? this.showLabels,
        tileAnimations: tileAnimations ?? this.tileAnimations,
        swipeUpDrawer: swipeUpDrawer ?? this.swipeUpDrawer,
      );

  Map<String, dynamic> toJson() => {
        'columns': columns,
        'accentId': accentId,
        'wallpaperId': wallpaperId,
        'lockWallpaperId': lockWallpaperId,
        'customWallpaperPath': customWallpaperPath,
        'customLockWallpaperPath': customLockWallpaperPath,
        'doubleTapLock': doubleTapLock,
        'showLabels': showLabels,
        'tileAnimations': tileAnimations,
        'swipeUpDrawer': swipeUpDrawer,
      };

  factory LauncherSettings.fromJson(Map<String, dynamic> json) => LauncherSettings(
        columns: (json['columns'] as int?) ?? 4,
        accentId: (json['accentId'] as String?) ?? 'amber',
        wallpaperId: (json['wallpaperId'] as String?) ?? 'midnight',
        lockWallpaperId: (json['lockWallpaperId'] as String?) ?? 'midnight',
        customWallpaperPath: json['customWallpaperPath'] as String?,
        customLockWallpaperPath: json['customLockWallpaperPath'] as String?,
        doubleTapLock: (json['doubleTapLock'] as bool?) ?? false,
        showLabels: (json['showLabels'] as bool?) ?? true,
        tileAnimations: (json['tileAnimations'] as bool?) ?? true,
        swipeUpDrawer: (json['swipeUpDrawer'] as bool?) ?? true,
      );

  String encode() => jsonEncode(toJson());

  factory LauncherSettings.decode(String s) =>
      LauncherSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

const _sentinel = Object();
