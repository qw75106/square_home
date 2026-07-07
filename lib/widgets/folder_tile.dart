import 'package:flutter/material.dart';

import '../models/tile_model.dart';

class FolderTileWidget extends StatelessWidget {
  final FolderTileItem item;
  final double cellSize;
  final Color accentColor;
  final bool showLabels;
  final bool editMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FolderTileWidget({
    super.key,
    required this.item,
    required this.cellSize,
    required this.accentColor,
    required this.showLabels,
    required this.editMode,
    required this.onTap,
    required this.onLongPress,
  });

  Color get _tileColor {
    if (item.colorHex != null) {
      return Color(int.parse(item.colorHex!.replaceFirst('#', '0xFF')));
    }
    return accentColor.withOpacity(0.85);
  }

  @override
  Widget build(BuildContext context) {
    final w = cellSize * item.size.spanCols;
    final h = cellSize * item.size.spanRows;
    const pad = 4.0;
    final innerW = w - pad * 2;
    final innerH = h - pad * 2;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            width: innerW,
            height: innerH,
            color: _tileColor,
            child: Stack(
              children: [
                // 2×2 mini icon grid
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: List.generate(
                        item.items.length.clamp(0, 4),
                        (i) => Container(
                          color: Colors.white.withOpacity(0.15),
                          child: const Icon(Icons.apps, color: Colors.white54, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                // Label scrim
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
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 5),
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
    );
  }
}
