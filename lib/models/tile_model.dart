import 'dart:convert';

enum TileSize { small, wide, tall, large, xlarge }

extension TileSizeExt on TileSize {
  int get spanCols => switch (this) {
        TileSize.small => 1,
        TileSize.wide => 2,
        TileSize.tall => 1,
        TileSize.large => 2,
        TileSize.xlarge => 4,
      };

  int get spanRows => switch (this) {
        TileSize.small => 1,
        TileSize.wide => 1,
        TileSize.tall => 2,
        TileSize.large => 2,
        TileSize.xlarge => 2,
      };

  String get label => switch (this) {
        TileSize.small => 'Small (1×1)',
        TileSize.wide => 'Wide (2×1)',
        TileSize.tall => 'Tall (1×2)',
        TileSize.large => 'Large (2×2)',
        TileSize.xlarge => 'Extra Large (4×2)',
      };
}

sealed class HomeItem {
  final String uid;
  final TileSize size;
  final String? colorHex;

  const HomeItem({required this.uid, required this.size, this.colorHex});

  Map<String, dynamic> toJson();

  HomeItem copyWith({TileSize? size, String? colorHex});

  static HomeItem fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'app' => AppTileItem.fromJson(json),
      'folder' => FolderTileItem.fromJson(json),
      _ => throw Exception('Unknown HomeItem type: ${json['type']}'),
    };
  }
}

final class AppTileItem extends HomeItem {
  final String appId;
  final String? customLabel;

  const AppTileItem({
    required super.uid,
    required super.size,
    super.colorHex,
    required this.appId,
    this.customLabel,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'app',
        'uid': uid,
        'size': size.name,
        'colorHex': colorHex,
        'appId': appId,
        'customLabel': customLabel,
      };

  @override
  AppTileItem copyWith({TileSize? size, String? colorHex, String? customLabel}) =>
      AppTileItem(
        uid: uid,
        size: size ?? this.size,
        colorHex: colorHex,
        appId: appId,
        customLabel: customLabel ?? this.customLabel,
      );

  static AppTileItem fromJson(Map<String, dynamic> json) => AppTileItem(
        uid: json['uid'] as String,
        size: TileSize.values.firstWhere(
          (s) => s.name == json['size'],
          orElse: () => TileSize.small,
        ),
        colorHex: json['colorHex'] as String?,
        appId: json['appId'] as String,
        customLabel: json['customLabel'] as String?,
      );
}

final class FolderTileItem extends HomeItem {
  final String name;
  final List<AppTileItem> items;

  const FolderTileItem({
    required super.uid,
    required super.size,
    super.colorHex,
    required this.name,
    required this.items,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'folder',
        'uid': uid,
        'size': size.name,
        'colorHex': colorHex,
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
      };

  @override
  FolderTileItem copyWith({
    TileSize? size,
    String? colorHex,
    String? name,
    List<AppTileItem>? items,
  }) =>
      FolderTileItem(
        uid: uid,
        size: size ?? this.size,
        colorHex: colorHex,
        name: name ?? this.name,
        items: items ?? this.items,
      );

  static FolderTileItem fromJson(Map<String, dynamic> json) => FolderTileItem(
        uid: json['uid'] as String,
        size: TileSize.values.firstWhere(
          (s) => s.name == json['size'],
          orElse: () => TileSize.large,
        ),
        colorHex: json['colorHex'] as String?,
        name: json['name'] as String,
        items: (json['items'] as List)
            .map((i) => AppTileItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}

String encodeItems(List<HomeItem> items) =>
    jsonEncode(items.map((i) => i.toJson()).toList());

List<HomeItem> decodeItems(String json) {
  final list = jsonDecode(json) as List;
  return list.map((i) => HomeItem.fromJson(i as Map<String, dynamic>)).toList();
}
