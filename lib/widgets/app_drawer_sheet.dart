import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_catalog.dart';
import '../models/tile_model.dart';
import '../providers/launcher_provider.dart';

class AppDrawerSheet extends StatefulWidget {
  const AppDrawerSheet({super.key});

  @override
  State<AppDrawerSheet> createState() => _AppDrawerSheetState();
}

class _AppDrawerSheetState extends State<AppDrawerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LauncherProvider>();
    final installedOnDevice = provider.deviceApps;
    final accentColor = Color(provider.settings.accent.hex);

    final List<_DisplayApp> displayApps;
    if (installedOnDevice.isNotEmpty) {
      displayApps = installedOnDevice
          .map((a) => _DisplayApp(
                id: a.packageName,
                label: a.label,
                icon: a.icon,
              ))
          .toList();
    } else {
      displayApps =
          kBuiltinApps.map((a) => _DisplayApp(id: a.id, label: a.label)).toList();
    }

    final filtered = _query.isEmpty
        ? displayApps
        : displayApps
            .where((a) => a.label.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      snap: true,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0F14),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search apps…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A1D27),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final app = filtered[i];
                  final alreadyAdded = provider.items.any(
                    (tile) => tile is AppTileItem && tile.appId == app.id,
                  );
                  return ListTile(
                    leading: SizedBox(
                      width: 44,
                      height: 44,
                      child: app.icon != null
                          ? Image.memory(app.icon!, fit: BoxFit.contain)
                          : Container(
                              color: accentColor,
                              child: const Icon(Icons.apps,
                                  color: Colors.white, size: 24),
                            ),
                    ),
                    title: Text(
                      app.label,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check,
                            color: Colors.white38, size: 18)
                        : IconButton(
                            icon: Icon(Icons.add, color: accentColor, size: 22),
                            onPressed: () {
                              provider.addApp(app.id);
                              Navigator.pop(ctx);
                            },
                          ),
                    onTap: alreadyAdded
                        ? null
                        : () {
                            provider.addApp(app.id);
                            Navigator.pop(ctx);
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayApp {
  final String id;
  final String label;
  final Uint8List? icon;

  const _DisplayApp({required this.id, required this.label, this.icon});
}
