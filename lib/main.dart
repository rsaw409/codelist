import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/contest.dart';
import 'data/contest_repository.dart';
import 'data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(ContestAdapter());
  final (contests, settings) = await (
    Hive.openBox<Contest>(ContestRepository.boxName),
    Hive.openBox<dynamic>(SettingsStore.boxName),
  ).wait;

  runApp(CodeListApp(
    repository: ContestRepository(contests: contests, settings: SettingsStore(settings)),
  ));
}
