import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'clist_api.dart';
import 'contest.dart';
import 'settings_store.dart';

/// Owns the cached contests and keeps them in sync with clist.by.
class ContestRepository {
  ContestRepository({
    required this.contests,
    required this.settings,
    ClistApi? api,
  }) : _api = api ?? ClistApi();

  static const boxName = 'ContestBox';
  static const _staleAfter = Duration(hours: 6);
  static const _iconConcurrency = 6;

  final Box<Contest> contests;
  final SettingsStore settings;
  final ClistApi _api;

  bool get hasData => contests.isNotEmpty;

  bool get isStale {
    final last = settings.lastRefresh;
    return last == null || DateTime.now().difference(last) > _staleAfter;
  }

  /// Fetches contests and platforms; platform logos are cached in the
  /// background so the list can render immediately.
  Future<void> refresh() async {
    final (List<Contest>, List<Platform>) result;
    try {
      result = await (_api.fetchContests(), _api.fetchPlatforms()).wait;
    } on ParallelWaitError<(List<Contest>?, List<Platform>?),
        (AsyncError?, AsyncError?)> catch (e) {
      // Surface the underlying failure rather than the wrapper.
      throw (e.errors.$1 ?? e.errors.$2)!.error;
    }
    final (fetched, platforms) = result;

    await contests.clear();
    await contests.addAll(fetched);
    await settings.setAllPlatforms(platforms.map((p) => p.name).toList()..sort());
    await settings.setLastRefresh(DateTime.now());

    final usedIds = fetched.map((c) => c.logoId).toSet();
    unawaited(_cacheLogos(platforms.where((p) => usedIds.contains(p.id))));
  }

  Future<void> _cacheLogos(Iterable<Platform> platforms) async {
    final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'logos'));
    await dir.create(recursive: true);

    final missing = platforms.where((platform) {
      final path = settings.logoPath(platform.id);
      return path == null || !File(path).existsSync();
    }).toList();

    for (var i = 0; i < missing.length; i += _iconConcurrency) {
      final batch = missing.skip(i).take(_iconConcurrency);
      await Future.wait(batch.map((platform) => _cacheLogo(dir, platform)));
    }
  }

  Future<void> _cacheLogo(Directory dir, Platform platform) async {
    try {
      final bytes = await _api.downloadIcon(platform.iconPath);
      final file = File(p.join(dir.path, '${platform.id}'));
      await file.writeAsBytes(bytes, flush: true);
      await settings.setLogoPath(platform.id, file.path);
    } catch (e) {
      // A missing logo falls back to the platform's initial; not worth failing over.
      debugPrint('Logo for ${platform.name} not cached: $e');
    }
  }
}
