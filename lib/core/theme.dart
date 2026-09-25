import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand seed used when the device doesn't provide dynamic (wallpaper) colors.
const _seed = Color(0xFF4F5BD5);

ThemeData buildTheme(ColorScheme? dynamicScheme, Brightness brightness) {
  final scheme =
      dynamicScheme?.harmonized() ?? ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      // The default overlay style paints the navigation bar opaque black.
      systemOverlayStyle: _systemBars(brightness),
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

extension on ColorScheme {
  /// Dynamic schemes from some OEMs only fill the legacy roles; re-deriving from
  /// the primary color gives a complete Material 3 tonal palette.
  ColorScheme harmonized() => ColorScheme.fromSeed(seedColor: primary, brightness: brightness);
}

SystemUiOverlayStyle _systemBars(Brightness brightness) {
  final icons = brightness == Brightness.light ? Brightness.dark : Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: icons,
    statusBarBrightness: brightness,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: icons,
    systemNavigationBarContrastEnforced: false,
  );
}
