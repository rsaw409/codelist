import 'package:flutter/widgets.dart';

import 'data/contest_repository.dart';
import 'data/settings_store.dart';

/// Makes the repository available to the widget tree without prop drilling.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.repository, required super.child});

  final ContestRepository repository;

  static ContestRepository repositoryOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.repository;

  static SettingsStore settingsOf(BuildContext context) => repositoryOf(context).settings;

  @override
  bool updateShouldNotify(AppScope oldWidget) => repository != oldWidget.repository;
}
