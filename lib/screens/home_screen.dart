import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/launcher_provider.dart';
import '../widgets/app_drawer_sheet.dart';
import '../widgets/home_grid.dart';
import '../widgets/settings_sheet.dart';
import 'lock_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _locked = false;
  int _lastTap = 0;

  void _onDoubleTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTap < 400) {
      setState(() => _locked = true);
    }
    _lastTap = now;
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  void _openAppDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AppDrawerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LauncherProvider>();
    final settings = provider.settings;

    if (_locked) {
      return LockScreen(
        wallpaper: settings.lockWallpaper,
        customWallpaperPath: settings.customLockWallpaperPath,
        onUnlock: () => setState(() => _locked = false),
      );
    }

    if (!provider.loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0D10),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white24,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    final insets = MediaQuery.of(context).padding;
    final accentColor = Color(settings.accent.hex);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && provider.editMode) {
          provider.exitEditMode();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (settings.customWallpaperPath != null)
              Image.file(
                File(settings.customWallpaperPath!),
                fit: BoxFit.cover,
              )
            else
              Container(color: Color(settings.wallpaper.primaryHex)),

            // Swipe-up detector
            if (settings.swipeUpDrawer)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -300) _openAppDrawer();
                },
                onTap: settings.doubleTapLock ? _onDoubleTap : null,
              ),

            // Main content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  _TopBar(
                    editMode: provider.editMode,
                    accentColor: accentColor,
                    onSettings: _openSettings,
                    onExitEdit: provider.exitEditMode,
                    onApps: _openAppDrawer,
                  ),
                  // Scrollable tile grid
                  Expanded(
                    child: GestureDetector(
                      onTap: provider.editMode ? provider.exitEditMode : null,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 80),
                        physics: provider.editMode
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        child: HomeGrid(
                          onOpenFolder: () {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit mode banner
            if (provider.editMode)
              Positioned(
                bottom: insets.bottom + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: provider.exitEditMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool editMode;
  final Color accentColor;
  final VoidCallback onSettings;
  final VoidCallback onExitEdit;
  final VoidCallback onApps;

  const _TopBar({
    required this.editMode,
    required this.accentColor,
    required this.onSettings,
    required this.onExitEdit,
    required this.onApps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / title
          const Text(
            'Square Home',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              if (!editMode)
                IconButton(
                  icon: const Icon(Icons.apps, color: Colors.white54, size: 22),
                  onPressed: onApps,
                  tooltip: 'All Apps',
                ),
              IconButton(
                icon: Icon(
                  editMode ? Icons.close : Icons.settings_outlined,
                  color: editMode ? Colors.white70 : Colors.white54,
                  size: 22,
                ),
                onPressed: editMode ? onExitEdit : onSettings,
                tooltip: editMode ? 'Exit edit mode' : 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
