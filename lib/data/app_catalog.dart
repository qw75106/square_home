/// Built-in fallback app catalog used when no package is provided or on
/// platforms that don't support [InstalledApps].
class CatalogApp {
  final String id;
  final String label;
  final String packageName;
  final String iconCodePoint; // Material icon codepoint
  final int iconColor;

  const CatalogApp({
    required this.id,
    required this.label,
    required this.packageName,
    required this.iconCodePoint,
    required this.iconColor,
  });
}

const kBuiltinApps = <CatalogApp>[
  CatalogApp(id: 'phone', label: 'Phone', packageName: 'com.android.dialer', iconCodePoint: 'e0b0', iconColor: 0xFF4CAF50),
  CatalogApp(id: 'messages', label: 'Messages', packageName: 'com.android.messaging', iconCodePoint: 'e0b7', iconColor: 0xFF2196F3),
  CatalogApp(id: 'camera', label: 'Camera', packageName: 'com.android.camera2', iconCodePoint: 'e3b0', iconColor: 0xFF9E9E9E),
  CatalogApp(id: 'gallery', label: 'Gallery', packageName: 'com.android.gallery3d', iconCodePoint: 'e2c7', iconColor: 0xFFFF9800),
  CatalogApp(id: 'settings', label: 'Settings', packageName: 'com.android.settings', iconCodePoint: 'e8b8', iconColor: 0xFF607D8B),
  CatalogApp(id: 'contacts', label: 'Contacts', packageName: 'com.android.contacts', iconCodePoint: 'e7fd', iconColor: 0xFF9C27B0),
  CatalogApp(id: 'calendar', label: 'Calendar', packageName: 'com.android.calendar', iconCodePoint: 'e935', iconColor: 0xFFF44336),
  CatalogApp(id: 'email', label: 'Email', packageName: 'com.android.email', iconCodePoint: 'e0be', iconColor: 0xFFE91E63),
  CatalogApp(id: 'browser', label: 'Browser', packageName: 'com.android.browser', iconCodePoint: 'e051', iconColor: 0xFF03A9F4),
  CatalogApp(id: 'maps', label: 'Maps', packageName: 'com.google.android.apps.maps', iconCodePoint: 'e55b', iconColor: 0xFF4CAF50),
  CatalogApp(id: 'music', label: 'Music', packageName: 'com.android.music', iconCodePoint: 'e405', iconColor: 0xFFFF5722),
  CatalogApp(id: 'clock', label: 'Clock', packageName: 'com.android.deskclock', iconCodePoint: 'e855', iconColor: 0xFF00BCD4),
  CatalogApp(id: 'calculator', label: 'Calculator', packageName: 'com.android.calculator2', iconCodePoint: 'e8f0', iconColor: 0xFF795548),
  CatalogApp(id: 'files', label: 'Files', packageName: 'com.android.documentsui', iconCodePoint: 'e2c7', iconColor: 0xFF607D8B),
  CatalogApp(id: 'youtube', label: 'YouTube', packageName: 'com.google.android.youtube', iconCodePoint: 'e1c4', iconColor: 0xFFF44336),
  CatalogApp(id: 'chrome', label: 'Chrome', packageName: 'com.android.chrome', iconCodePoint: 'e051', iconColor: 0xFF1976D2),
  CatalogApp(id: 'store', label: 'Play Store', packageName: 'com.android.vending', iconCodePoint: 'e8a1', iconColor: 0xFF4CAF50),
  CatalogApp(id: 'drive', label: 'Drive', packageName: 'com.google.android.apps.docs', iconCodePoint: 'e2c7', iconColor: 0xFF1976D2),
  CatalogApp(id: 'photos', label: 'Photos', packageName: 'com.google.android.apps.photos', iconCodePoint: 'e3b2', iconColor: 0xFFE91E63),
  CatalogApp(id: 'weather', label: 'Weather', packageName: 'com.weather.Weather', iconCodePoint: 'e2bd', iconColor: 0xFF03A9F4),
];

CatalogApp? findCatalogApp(String id) {
  try {
    return kBuiltinApps.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
