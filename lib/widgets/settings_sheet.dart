import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/launcher_settings.dart';
import '../providers/launcher_provider.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LauncherProvider>();
    final settings = provider.settings;
    final accentColor = Color(settings.accent.hex);

    const sectionStyle = TextStyle(
      color: Colors.white38,
      fontSize: 10,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w700,
    );
    const labelStyle = TextStyle(color: Colors.white, fontSize: 14);
    const sublabelStyle = TextStyle(color: Colors.white54, fontSize: 12);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      snap: true,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0F14),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  const Text('Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),

                  // ── ACCENT COLOR ───────────────────────────────────────────
                  const Text('ACCENT COLOR', style: sectionStyle),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kAccentOptions.map((opt) {
                      final selected = settings.accentId == opt.id;
                      return GestureDetector(
                        onTap: () => provider.setAccent(opt.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(opt.hex),
                            border: selected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── COLUMNS ────────────────────────────────────────────────
                  const Text('GRID COLUMNS', style: sectionStyle),
                  const SizedBox(height: 10),
                  Row(
                    children: [4, 6].map((c) {
                      final selected = settings.columns == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => provider.setColumns(c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accentColor
                                  : const Color(0xFF1A1D27),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$c',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── WALLPAPER ──────────────────────────────────────────────
                  const Text('WALLPAPER', style: sectionStyle),
                  const SizedBox(height: 10),
                  _WallpaperRow(
                    options: kWallpaperOptions,
                    selectedId: settings.wallpaperId,
                    onSelect: provider.setWallpaper,
                  ),
                  const SizedBox(height: 8),
                  _PhotoPickerRow(
                    path: settings.customWallpaperPath,
                    label: 'Home wallpaper photo',
                    onPick: (path) => provider.setCustomWallpaperPath(path),
                    onClear: () => provider.setCustomWallpaperPath(null),
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 24),

                  // ── LOCK WALLPAPER ─────────────────────────────────────────
                  const Text('LOCK SCREEN WALLPAPER', style: sectionStyle),
                  const SizedBox(height: 10),
                  _WallpaperRow(
                    options: kWallpaperOptions,
                    selectedId: settings.lockWallpaperId,
                    onSelect: provider.setLockWallpaper,
                  ),
                  const SizedBox(height: 8),
                  _PhotoPickerRow(
                    path: settings.customLockWallpaperPath,
                    label: 'Lock screen photo',
                    onPick: (path) => provider.setCustomLockWallpaperPath(path),
                    onClear: () => provider.setCustomLockWallpaperPath(null),
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 24),

                  // ── BEHAVIOUR ──────────────────────────────────────────────
                  const Text('BEHAVIOUR', style: sectionStyle),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    label: 'Show tile labels',
                    value: settings.showLabels,
                    onChanged: provider.setShowLabels,
                  ),
                  _ToggleRow(
                    label: 'Tile animations',
                    value: settings.tileAnimations,
                    onChanged: provider.setTileAnimations,
                  ),
                  _ToggleRow(
                    label: 'Swipe-up app drawer',
                    value: settings.swipeUpDrawer,
                    onChanged: provider.setSwipeUpDrawer,
                  ),
                  _ToggleRow(
                    label: 'Double-tap to lock',
                    value: settings.doubleTapLock,
                    onChanged: provider.setDoubleTapLock,
                  ),
                  const SizedBox(height: 24),

                  // ── RESET ──────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1D27),
                          title: const Text('Reset to defaults',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              'This will clear all tiles and settings.',
                              style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Reset',
                                    style:
                                        TextStyle(color: Colors.redAccent))),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        provider.resetToDefault();
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Row(
                        children: [
                          Icon(Icons.refresh, color: Colors.redAccent, size: 20),
                          SizedBox(width: 10),
                          Text('Reset to defaults',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperRow extends StatelessWidget {
  final List<WallpaperOption> options;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _WallpaperRow({
    required this.options,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final selected = selectedId == opt.id;
        return GestureDetector(
          onTap: () => onSelect(opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.only(right: 8),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(opt.primaryHex),
              border: selected
                  ? Border.all(color: Colors.white, width: 2.5)
                  : Border.all(color: Colors.white12, width: 1),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PhotoPickerRow extends StatelessWidget {
  final String? path;
  final String label;
  final ValueChanged<String> onPick;
  final VoidCallback onClear;
  final Color accentColor;

  const _PhotoPickerRow({
    required this.path,
    required this.label,
    required this.onPick,
    required this.onClear,
    required this.accentColor,
  });

  Future<void> _pick() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xfile != null) onPick(xfile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: _pick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image_outlined,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  path != null ? 'Change photo…' : 'Upload photo…',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        if (path != null) ...[
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(path!),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: Colors.white38, size: 18),
          ),
        ],
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Color(
              context.watch<LauncherProvider>().settings.accent.hex),
        ),
      ],
    );
  }
}
