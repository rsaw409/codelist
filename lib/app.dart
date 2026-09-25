import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_scope.dart';
import 'core/theme.dart';
import 'data/contest_repository.dart';
import 'data/settings_store.dart';
import 'features/contests/contests_page.dart';

class CodeListApp extends StatelessWidget {
  const CodeListApp({super.key, required this.repository});

  final ContestRepository repository;

  @override
  Widget build(BuildContext context) {
    final settings = repository.settings;

    return AppScope(
      repository: repository,
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => ValueListenableBuilder(
          valueListenable: settings.box.listenable(keys: const [SettingsStore.themeModeKey]),
          builder: (context, _, __) => MaterialApp(
            title: 'CodeList',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const _NoStretchScrollBehavior(),
            themeMode: settings.themeMode,
            theme: buildTheme(lightDynamic, Brightness.light),
            darkTheme: buildTheme(darkDynamic, Brightness.dark),
            home: const ContestsPage(),
          ),
        ),
      ),
    );
  }
}

/// Android's stretch overscroll distorts text and stretches the pinned app bar
/// along with the list; pull-to-refresh already signals the top edge.
class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
