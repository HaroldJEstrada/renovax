import 'package:flutter/material.dart';

import 'theme_store_stub.dart'
    if (dart.library.js_interop) 'theme_store_web.dart';

final appTheme = ValueNotifier<ThemeMode>(
  readDarkMode() ? ThemeMode.dark : ThemeMode.light,
);
bool get isDark => appTheme.value == ThemeMode.dark;
Color get headingColor =>
    isDark ? const Color(0xFFF2E9ED) : const Color(0xFF1D385C);
Color get accentColor =>
    isDark ? const Color(0xFFFF6078) : const Color(0xFF4068AA);
Color get navSelectionColor =>
    isDark ? const Color(0xFF5B303D) : const Color(0xFF4068AA);
Color get paper => isDark ? const Color(0xFF15161B) : const Color(0xFFEDF4FF);
Color get panelTint =>
    isDark ? const Color(0xFF35232C) : const Color(0xFFE1EDFF);
Color get borderColor =>
    isDark ? const Color(0xFF65404B) : const Color(0xFFBDD0EF);
Color get surfaceColor =>
    isDark ? const Color(0xFF222329) : const Color(0xFFF8FBFF);
Color get mutedColor =>
    isDark ? const Color(0xFFC6B9C0) : const Color(0xFF526F99);
Color get buttonTextColor => isDark ? const Color(0xFF1B1015) : Colors.white;
Color get glowColor =>
    isDark ? const Color(0x224E1829) : const Color(0x144068AA);
List<Color> get headerColors => isDark
    ? [const Color(0xFF422730), const Color(0xFF1B1C22)]
    : [const Color(0xFF294F90), const Color(0xFF1D385C)];
List<Color> get heroColors => isDark
    ? [const Color(0xFF3D2B33), const Color(0xFF1C1D23)]
    : [const Color(0xFFD9E8FF), const Color(0xFFF5F9FF)];

void toggleTheme() {
  appTheme.value = isDark ? ThemeMode.light : ThemeMode.dark;
  saveDarkMode(isDark);
}

ThemeData buildBrandTheme(bool dark) {
  final primary = dark ? const Color(0xFFFF6078) : const Color(0xFF4068AA);
  final text = dark ? const Color(0xFFF2E9ED) : const Color(0xFF1D385C);
  final surface = dark ? const Color(0xFF222329) : const Color(0xFFF8FBFF);
  final border = dark ? const Color(0xFF65404B) : const Color(0xFFBDD0EF);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: dark ? const Color(0xFF1B1015) : Colors.white,
        surface: surface,
        onSurface: text,
        outline: border,
        primaryContainer: dark
            ? const Color(0xFF51303A)
            : const Color(0xFFDCE9FF),
        onPrimaryContainer: text,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: dark
        ? const Color(0xFF15161B)
        : const Color(0xFFEDF4FF),
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF1B1C22) : const Color(0xFF1D385C),
      foregroundColor: Colors.white,
    ),
    dividerColor: border,
    iconTheme: IconThemeData(color: primary),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dark ? const Color(0xFF35232C) : const Color(0xFFE1EDFF),
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: border),
      labelStyle: TextStyle(color: text),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: text,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: dark ? const Color(0xFF292A31) : Colors.white,
    ),
  );
}

class ThemeToggle extends StatelessWidget {
  final bool compact;
  const ThemeToggle({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appTheme,
    builder: (context, mode, _) => compact
        ? IconButton(
            tooltip: isDark ? 'Activar modo claro' : 'Activar modo oscuro',
            onPressed: toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          )
        : TextButton.icon(
            onPressed: toggleTheme,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            label: Text(isDark ? 'Claro' : 'Oscuro'),
          ),
  );
}
