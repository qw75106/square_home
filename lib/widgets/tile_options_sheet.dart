import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tile_model.dart';
import '../providers/launcher_provider.dart';

const _kColorPalette = [
  null, // accent / default
  '#D32F2F', // red
  '#E64A19', // deep-orange
  '#F57F17', // amber
  '#388E3C', // green
  '#0288D1', // blue
  '#7B1FA2', // purple
  '#00838F', // cyan
  '#424242', // grey
];

class TileOptionsSheet extends StatelessWidget {
  final HomeItem item;

  const TileOptionsSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LauncherProvider>();
    final accentColor = Color(provider.settings.accent.hex);
    const sectionStyle = TextStyle(
      color: Colors.white38,
      fontSize: 11,
      letterSpacing: 1.0,
      fontWeight: FontWeight.w600,
    );
    const labelStyle = TextStyle(color: Colors.white70, fontSize: 13);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D27),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              item is AppTileItem
                  ? (item as AppTileItem).appId
                  : (item as FolderTileItem).name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // SIZE
            const Text('SIZE', style: sectionStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TileSize.values.map((size) {
                final selected = item.size == size;
                return GestureDetector(
                  onTap: () {
                    provider.setTileSize(item.uid, size);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? accentColor : const Color(0xFF252836),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(size.label, style: labelStyle.copyWith(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // COLOR
            const Text('COLOR', style: sectionStyle),
            const SizedBox(height: 8),
            Row(
              children: _kColorPalette.map((hex) {
                final color = hex == null
                    ? accentColor
                    : Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final currentHex = item.colorHex;
                final selected = hex == null
                    ? currentHex == null
                    : currentHex == hex;
                return GestureDetector(
                  onTap: () {
                    provider.setTileColor(item.uid, hex);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: selected
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                    ),
                    child: selected && hex == null
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // REMOVE
            GestureDetector(
              onTap: () {
                provider.removeItem(item.uid);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Remove from home',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
