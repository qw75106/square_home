import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/app_catalog.dart';
import '../models/tile_model.dart';
import '../providers/launcher_provider.dart';

class AppTileWidget extends StatelessWidget {
  final AppTileItem item;
  final double cellSize;
  final Color accentColor;
  final bool showLabels;
  final bool editMode;
  final bool animate;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Uint8List? deviceIcon;

  const AppTileWidget({
    super.key,
    required this.item,
    required this.cellSize,
    required this.accentColor,
    required this.showLabels,
    required this.editMode,
    required this.animate,
    required this.onTap,
    required this.onLongPress,
    this.deviceIcon,
  });

  Color get _tileColor {
    if (item.colorHex != null) {
      return Color(int.parse(item.colorHex!.replaceFirst('#', '0xFF')));
    }
    return accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final app = findCatalogApp(item.appId);
    final w = cellSize * item.size.spanCols;
    final h = cellSize * item.size.spanRows;
    const pad = 4.0;

    return AnimatedContainer(
      duration: animate ? const Duration(milliseconds: 120) : Duration.zero,
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            // Tile background
            Container(
              width: w - pad * 2,
              height: h - pad * 2,
              color: _tileColor,
              child: Stack(
                children: [
                  // Icon
                  Positioned.fill(
                    child: Align(
                      alignment: showLabels ? Alignment.topCenter : Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: showLabels ? h * 0.15 : 0),
                        child: _buildIcon(app, (w - pad * 2) * 0.48),
                      ),
                    ),
                  ),
                  // Label scrim + text
                  if (showLabels)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(6, 12, 6, 5),
                        child: Text(
                          item.customLabel ?? app?.label ?? item.appId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Edit mode overlay
            if (editMode)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(CatalogApp? app, double size) {
    if (deviceIcon != null) {
      return Image.memory(deviceIcon!, width: size, height: size, fit: BoxFit.contain);
    }
    if (app != null) {
      return Icon(
        IconData(int.parse(app.iconCodePoint, radix: 16),
            fontFamily: 'MaterialIcons'),
        size: size,
        color: Colors.white,
      );
    }
    return Icon(Icons.apps, size: size, color: Colors.white);
  }
}
