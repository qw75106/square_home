import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/app_catalog.dart';
import '../models/launcher_settings.dart';
import '../models/tile_model.dart';

const _kItemsKey = 'launcher_items_v1';
const _kSettingsKey = 'launcher_settings_v1';

final _uuid = Uuid();

class DeviceApp {
  final String packageName;
  final String label;
  final Uint8List? icon;

  const DeviceApp({
    required this.packageName,
    required this.label,
    this.icon,
  });
}

class LauncherProvider extends ChangeNotifier {
  List<HomeItem> _items = _defaultItems();
  LauncherSettings _settings = const LauncherSettings();
  List<DeviceApp> _deviceApps = [];
  bool _loaded = false;
  bool _editMode = false;
  String? _draggingUid;

  List<HomeItem> get items => _items;
  LauncherSettings get settings => _settings;
  List<DeviceApp> get deviceApps => _deviceApps;
  bool get loaded => _loaded;
  bool get editMode => _editMode;
  String? get draggingUid => _draggingUid;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_kItemsKey);
    final settingsJson = prefs.getString(_kSettingsKey);

    if (itemsJson != null) {
      try {
        _items = decodeItems(itemsJson);
      } catch (_) {
        _items = _defaultItems();
      }
    }
    if (settingsJson != null) {
      try {
        _settings = LauncherSettings.decode(settingsJson);
      } catch (_) {}
    }

    _loaded = true;
    notifyListeners();

    _loadDeviceApps();
  }

  Future<void> _loadDeviceApps() async {
    if (!Platform.isAndroid) return;
    try {
      final apps = await InstalledApps.getInstalledApps(true, true, '');
      _deviceApps = apps
          .map((a) => DeviceApp(
                packageName: a.packageName ?? '',
                label: a.name ?? a.packageName ?? '',
                icon: a.icon,
              ))
          .where((a) => a.packageName.isNotEmpty)
          .toList()
        ..sort((a, b) => a.label.compareTo(b.label));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kItemsKey, encodeItems(_items));
    await prefs.setString(_kSettingsKey, _settings.encode());
  }

  // ─── Edit mode ───────────────────────────────────────────────────────────

  void enterEditMode() {
    _editMode = true;
    notifyListeners();
  }

  void exitEditMode() {
    _editMode = false;
    _draggingUid = null;
    notifyListeners();
  }

  void setDragging(String? uid) {
    _draggingUid = uid;
    notifyListeners();
  }

  // ─── Items ────────────────────────────────────────────────────────────────

  void addApp(String appId) {
    _items = [
      ..._items,
      AppTileItem(
        uid: _uuid.v4(),
        size: _settings.columns >= 6 ? TileSize.small : TileSize.small,
        appId: appId,
      ),
    ];
    _persist();
    notifyListeners();
  }

  void removeItem(String uid) {
    _items = _items.where((i) => i.uid != uid).toList();
    _persist();
    notifyListeners();
  }

  void reorderItems(int oldIndex, int newIndex) {
    final list = List<HomeItem>.from(_items);
    final item = list.removeAt(oldIndex);
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(adjusted, item);
    _items = list;
    _persist();
    notifyListeners();
  }

  void moveItem(String uid, int newIndex) {
    final oldIndex = _items.indexWhere((i) => i.uid == uid);
    if (oldIndex < 0) return;
    reorderItems(oldIndex, newIndex.clamp(0, _items.length));
  }

  void setTileSize(String uid, TileSize size) {
    _items = _items.map((i) => i.uid == uid ? i.copyWith(size: size) : i).toList();
    _persist();
    notifyListeners();
  }

  void setTileColor(String uid, String? colorHex) {
    _items = _items.map((i) => i.uid == uid ? i.copyWith(colorHex: colorHex) : i).toList();
    _persist();
    notifyListeners();
  }

  void renameFolder(String uid, String name) {
    _items = _items.map((i) {
      if (i.uid == uid && i is FolderTileItem) {
        return (i as FolderTileItem).copyWith(name: name);
      }
      return i;
    }).toList();
    _persist();
    notifyListeners();
  }

  void createFolder(String uid1, String uid2) {
    final a = _items.firstWhere((i) => i.uid == uid1);
    final b = _items.firstWhere((i) => i.uid == uid2);
    if (a is! AppTileItem || b is! AppTileItem) return;

    final folder = FolderTileItem(
      uid: _uuid.v4(),
      size: TileSize.large,
      name: 'Folder',
      items: [a, b],
    );

    _items = _items
        .where((i) => i.uid != uid1 && i.uid != uid2)
        .followedBy([folder])
        .toList();
    _persist();
    notifyListeners();
  }

  void addToFolder(String folderUid, String appUid) {
    final app = _items.firstWhere((i) => i.uid == appUid);
    if (app is! AppTileItem) return;
    _items = _items.map((i) {
      if (i.uid == folderUid && i is FolderTileItem) {
        return (i as FolderTileItem).copyWith(items: [...i.items, app]);
      }
      return i;
    }).toList();
    _items = _items.where((i) => i.uid != appUid).toList();
    _persist();
    notifyListeners();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  void setColumns(int columns) {
    _settings = _settings.copyWith(columns: columns);
    _persist();
    notifyListeners();
  }

  void setAccent(String accentId) {
    _settings = _settings.copyWith(accentId: accentId);
    _persist();
    notifyListeners();
  }

  void setWallpaper(String wallpaperId) {
    _settings = _settings.copyWith(wallpaperId: wallpaperId);
    _persist();
    notifyListeners();
  }

  void setLockWallpaper(String wallpaperId) {
    _settings = _settings.copyWith(lockWallpaperId: wallpaperId);
    _persist();
    notifyListeners();
  }

  void setCustomWallpaperPath(String? path) {
    _settings = _settings.copyWith(customWallpaperPath: path);
    _persist();
    notifyListeners();
  }

  void setCustomLockWallpaperPath(String? path) {
    _settings = _settings.copyWith(customLockWallpaperPath: path);
    _persist();
    notifyListeners();
  }

  void setDoubleTapLock(bool value) {
    _settings = _settings.copyWith(doubleTapLock: value);
    _persist();
    notifyListeners();
  }

  void setShowLabels(bool value) {
    _settings = _settings.copyWith(showLabels: value);
    _persist();
    notifyListeners();
  }

  void setTileAnimations(bool value) {
    _settings = _settings.copyWith(tileAnimations: value);
    _persist();
    notifyListeners();
  }

  void setSwipeUpDrawer(bool value) {
    _settings = _settings.copyWith(swipeUpDrawer: value);
    _persist();
    notifyListeners();
  }

  void resetToDefault() {
    _items = _defaultItems();
    _settings = const LauncherSettings();
    _persist();
    notifyListeners();
  }

  DeviceApp? findDeviceApp(String packageName) {
    try {
      return _deviceApps.firstWhere((a) => a.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  Future<void> launchApp(String packageName) async {
    if (!Platform.isAndroid) return;
    try {
      await InstalledApps.startApp(packageName);
    } catch (_) {}
  }
}

List<HomeItem> _defaultItems() => [
      AppTileItem(uid: 'phone', size: TileSize.small, appId: 'phone'),
      AppTileItem(uid: 'messages', size: TileSize.small, appId: 'messages'),
      AppTileItem(uid: 'camera', size: TileSize.small, appId: 'camera'),
      AppTileItem(uid: 'settings', size: TileSize.small, appId: 'settings'),
      AppTileItem(uid: 'email', size: TileSize.wide, appId: 'email'),
      AppTileItem(uid: 'contacts', size: TileSize.wide, appId: 'contacts'),
      FolderTileItem(
        uid: 'folder1',
        size: TileSize.large,
        name: 'Social',
        items: [
          AppTileItem(uid: 'youtube', size: TileSize.small, appId: 'youtube'),
          AppTileItem(uid: 'photos', size: TileSize.small, appId: 'photos'),
          AppTileItem(uid: 'maps', size: TileSize.small, appId: 'maps'),
          AppTileItem(uid: 'store', size: TileSize.small, appId: 'store'),
        ],
      ),
      AppTileItem(uid: 'calendar', size: TileSize.wide, appId: 'calendar'),
      AppTileItem(uid: 'clock', size: TileSize.small, appId: 'clock'),
      AppTileItem(uid: 'calculator', size: TileSize.small, appId: 'calculator'),
      AppTileItem(uid: 'browser', size: TileSize.wide, appId: 'browser'),
    ];
