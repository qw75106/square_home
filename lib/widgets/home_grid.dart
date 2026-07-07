import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tile_model.dart';
import '../providers/launcher_provider.dart';
import '../utils/grid_packer.dart';
import 'app_tile.dart';
import 'folder_tile.dart';
import 'tile_options_sheet.dart';

class HomeGrid extends StatefulWidget {
  final VoidCallback onOpenFolder;

  const HomeGrid({super.key, required this.onOpenFolder});

  @override
  State<HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  String? _dragOverUid;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LauncherProvider>();
    final settings = provider.settings;
    final items = provider.items;
    final columns = settings.columns;
    final accentColor = Color(settings.accent.hex);

    final screenW = MediaQuery.of(context).size.width;
    final cellSize = screenW / columns;
    const tilePad = 4.0;

    final packed = packTiles(items, columns);
    final rows = totalRows(packed);
    final gridH = rows * cellSize;

    return SizedBox(
      width: screenW,
      height: gridH + tilePad * 2,
      child: Stack(
        children: List.generate(packed.length, (idx) {
          final pt = packed[idx];
          final item = items[pt.index];
          final left = pt.col * cellSize + tilePad;
          final top = pt.row * cellSize + tilePad;
          final w = item.size.spanCols * cellSize;
          final h = item.size.spanRows * cellSize;
          final isDragging = provider.draggingUid == item.uid;

          Widget tileWidget;
          if (item is AppTileItem) {
            final deviceApp = provider.findDeviceApp(
              _packageNameFor(item.appId),
            );
            tileWidget = AppTileWidget(
              item: item,
              cellSize: cellSize,
              accentColor: accentColor,
              showLabels: settings.showLabels,
              editMode: provider.editMode,
              animate: settings.tileAnimations,
              deviceIcon: deviceApp?.icon,
              onTap: () => _onTap(context, item),
              onLongPress: () => _onLongPress(context, item),
            );
          } else if (item is FolderTileItem) {
            tileWidget = FolderTileWidget(
              item: item,
              cellSize: cellSize,
              accentColor: accentColor,
              showLabels: settings.showLabels,
              editMode: provider.editMode,
              onTap: () => _onTapFolder(context, item),
              onLongPress: () => _onLongPress(context, item),
            );
          } else {
            tileWidget = const SizedBox.shrink();
          }

          return Positioned(
            left: left,
            top: top,
            width: w,
            height: h,
            child: provider.editMode
                ? LongPressDraggable<String>(
                    data: item.uid,
                    delay: const Duration(milliseconds: 120),
                    onDragStarted: () => provider.setDragging(item.uid),
                    onDragEnd: (_) => provider.setDragging(null),
                    feedback: Opacity(
                      opacity: 0.85,
                      child: SizedBox(
                        width: w - tilePad * 2,
                        height: h - tilePad * 2,
                        child: tileWidget,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.25,
                      child: tileWidget,
                    ),
                    child: DragTarget<String>(
                      onWillAcceptWithDetails: (details) =>
                          details.data != item.uid,
                      onAcceptWithDetails: (details) {
                        final fromIdx = provider.items
                            .indexWhere((i) => i.uid == details.data);
                        final toIdx = provider.items
                            .indexWhere((i) => i.uid == item.uid);
                        if (fromIdx >= 0 && toIdx >= 0) {
                          provider.reorderItems(fromIdx, toIdx);
                        }
                      },
                      builder: (ctx, candidateData, rejectedData) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          transform: candidateData.isNotEmpty
                              ? (Matrix4.identity()..scale(1.05))
                              : Matrix4.identity(),
                          child: tileWidget,
                        );
                      },
                    ),
                  )
                : tileWidget,
          );
        }),
      ),
    );
  }

  void _onTap(BuildContext context, AppTileItem item) {
    final provider = context.read<LauncherProvider>();
    if (provider.editMode) {
      _showOptions(context, item);
      return;
    }
    final pkg = _packageNameFor(item.appId);
    if (pkg.isNotEmpty) provider.launchApp(pkg);
  }

  void _onTapFolder(BuildContext context, FolderTileItem item) {
    final provider = context.read<LauncherProvider>();
    if (provider.editMode) {
      _showOptions(context, item);
      return;
    }
    widget.onOpenFolder();
    _showFolderModal(context, item);
  }

  void _onLongPress(BuildContext context, HomeItem item) {
    final provider = context.read<LauncherProvider>();
    if (!provider.editMode) provider.enterEditMode();
    _showOptions(context, item);
  }

  void _showOptions(BuildContext context, HomeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TileOptionsSheet(item: item),
    );
  }

  void _showFolderModal(BuildContext context, FolderTileItem folder) {
    final provider = context.read<LauncherProvider>();
    final accentColor = Color(provider.settings.accent.hex);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1D27),
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
              const SizedBox(height: 12),
              Text(
                folder.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  controller: scroll,
                  crossAxisCount: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: folder.items.map((app) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        provider.launchApp(_packageNameFor(app.appId));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            color: accentColor,
                            child: const Icon(Icons.apps,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.appId,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _packageNameFor(String appId) {
    // Look up in catalog first, then treat as raw package name
    final catalog = _catalogPackages[appId];
    return catalog ?? appId;
  }

  static const _catalogPackages = {
    'phone': 'com.android.dialer',
    'messages': 'com.android.messaging',
    'camera': 'com.android.camera2',
    'gallery': 'com.android.gallery3d',
    'settings': 'com.android.settings',
    'contacts': 'com.android.contacts',
    'calendar': 'com.android.calendar',
    'email': 'com.android.email',
    'browser': 'com.android.browser',
    'maps': 'com.google.android.apps.maps',
    'music': 'com.android.music',
    'clock': 'com.android.deskclock',
    'calculator': 'com.android.calculator2',
    'files': 'com.android.documentsui',
    'youtube': 'com.google.android.youtube',
    'chrome': 'com.android.chrome',
    'store': 'com.android.vending',
    'drive': 'com.google.android.apps.docs',
    'photos': 'com.google.android.apps.photos',
  };
}
