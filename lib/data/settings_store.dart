import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Typed access to the untyped `settingBox`.
///
/// Key names are kept from earlier versions so existing installs keep their
/// preferences. Logo file paths are stored under the platform's integer id.
class SettingsStore {
  SettingsStore(this.box);

  final Box<dynamic> box;

  static const boxName = 'settingBox';
  static const _useLocalTimeKey = 'isIST';
  static const _allPlatformsKey = 'allPlatform';
  static const _selectedPlatformsKey = 'selectedPlatform';
  static const themeModeKey = 'themeMode';
  static const _lastRefreshKey = 'lastRefresh';

  /// Keys that affect how the contest list is rendered.
  static const listKeys = [_useLocalTimeKey, _selectedPlatformsKey];

  bool get useLocalTime => box.get(_useLocalTimeKey, defaultValue: true) as bool;
  Future<void> setUseLocalTime(bool value) => box.put(_useLocalTimeKey, value);

  List<String> get allPlatforms =>
      List<String>.from(box.get(_allPlatformsKey, defaultValue: const <String>[]) as List);
  Future<void> setAllPlatforms(List<String> value) => box.put(_allPlatformsKey, value);

  Set<String> get selectedPlatforms =>
      Set<String>.from(box.get(_selectedPlatformsKey, defaultValue: const <String>[]) as List);
  Future<void> setSelectedPlatforms(Iterable<String> value) =>
      box.put(_selectedPlatformsKey, value.toList());

  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[box.get(themeModeKey)] ?? ThemeMode.system;
  Future<void> setThemeMode(ThemeMode value) => box.put(themeModeKey, value.name);

  DateTime? get lastRefresh {
    final millis = box.get(_lastRefreshKey) as int?;
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setLastRefresh(DateTime value) =>
      box.put(_lastRefreshKey, value.millisecondsSinceEpoch);

  String? logoPath(int platformId) => box.get(platformId) as String?;
  Future<void> setLogoPath(int platformId, String path) => box.put(platformId, path);
}
