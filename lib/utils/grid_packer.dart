import '../models/tile_model.dart';

class PackedTile {
  final int index;
  final int row;
  final int col;
  final TileSize size;

  const PackedTile({
    required this.index,
    required this.row,
    required this.col,
    required this.size,
  });
}

/// Packs [items] into a [columns]-wide grid using a greedy left-to-right,
/// top-to-bottom algorithm, identical to the Expo Metro packer.
List<PackedTile> packTiles(List<HomeItem> items, int columns) {
  final grid = <List<bool>>[];
  final result = <PackedTile>[];

  bool canPlace(int row, int col, int tileRows, int tileCols) {
    if (col + tileCols > columns) return false;
    for (var r = row; r < row + tileRows; r++) {
      while (grid.length <= r) {
        grid.add(List.filled(columns, false));
      }
      for (var c = col; c < col + tileCols; c++) {
        if (grid[r][c]) return false;
      }
    }
    return true;
  }

  void occupy(int row, int col, int tileRows, int tileCols) {
    for (var r = row; r < row + tileRows; r++) {
      while (grid.length <= r) {
        grid.add(List.filled(columns, false));
      }
      for (var c = col; c < col + tileCols; c++) {
        grid[r][c] = true;
      }
    }
  }

  for (var i = 0; i < items.length; i++) {
    final size = items[i].size;
    final tileRows = size.spanRows;
    final tileCols = size.spanCols.clamp(1, columns);
    var placed = false;

    for (var row = 0; !placed; row++) {
      while (grid.length <= row) {
        grid.add(List.filled(columns, false));
      }
      for (var col = 0; col <= columns - tileCols; col++) {
        if (canPlace(row, col, tileRows, tileCols)) {
          result.add(PackedTile(index: i, row: row, col: col, size: size));
          occupy(row, col, tileRows, tileCols);
          placed = true;
          break;
        }
      }
    }
  }

  return result;
}

/// Returns the total number of rows occupied by [packed] items.
int totalRows(List<PackedTile> packed) {
  if (packed.isEmpty) return 0;
  return packed.fold(0, (max, t) => t.row + t.size.spanRows > max ? t.row + t.size.spanRows : max);
}
