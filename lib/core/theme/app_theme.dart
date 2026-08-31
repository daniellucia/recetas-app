import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Construye los `ThemeData` claro/oscuro replicando el sistema de diseño
/// de la web (ver `AppColors`): naranja de marca como acento, radios
/// amplios, sombras sutiles y una tipografía cercana a SF Pro (SF nativo en
/// iOS, Inter empaquetado como fallback en Android).
abstract final class AppTheme {
  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static ThemeData light() => _build(
        brightness: Brightness.light,
        windowBackground: AppColors.windowBackgroundLight,
        navBackground: AppColors.navBackgroundLight,
        surface: AppColors.surfaceLight,
        hairline: AppColors.hairlineLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        windowBackground: AppColors.windowBackgroundDark,
        navBackground: AppColors.navBackgroundDark,
        surface: AppColors.surfaceDark,
        hairline: AppColors.hairlineDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color windowBackground,
    required Color navBackground,
    required Color surface,
    required Color hairline,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = brightness == Brightness.dark;
    final onBrand = Colors.white;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brand500,
      onPrimary: onBrand,
      primaryContainer:
          isDark ? AppColors.brand800 : AppColors.brand100,
      onPrimaryContainer:
          isDark ? AppColors.brand100 : AppColors.brand800,
      secondary: AppColors.brand600,
      onSecondary: onBrand,
      secondaryContainer:
          isDark ? AppColors.brand900 : AppColors.brand50,
      onSecondaryContainer:
          isDark ? AppColors.brand100 : AppColors.brand700,
      tertiary: AppColors.brand700,
      onTertiary: onBrand,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerLowest: windowBackground,
      surfaceContainerLow: windowBackground,
      surfaceContainer: navBackground,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: surface,
      onSurfaceVariant: textSecondary,
      outline: hairline,
      outlineVariant: hairline,
      inverseSurface: isDark ? AppColors.surfaceLight : AppColors.surfaceDark,
      onInverseSurface:
          isDark ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      inversePrimary: AppColors.brand300,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final baseTextTheme = Typography.material2021(
      platform: TargetPlatform.iOS,
    ).black.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        );

    final textTheme = (_isAndroid
            ? baseTextTheme.apply(fontFamily: 'Inter')
            : baseTextTheme)
        .copyWith(
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 15,
        color: textSecondary,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: textSecondary,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    const cardRadius = BorderRadius.all(Radius.circular(16));
    const buttonRadius = BorderRadius.all(Radius.circular(8));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: windowBackground,
      canvasColor: windowBackground,
      dividerColor: hairline,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      fontFamily: _isAndroid ? 'Inter' : null,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: windowBackground,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: AppColors.brand500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brand500.withValues(alpha: 0.4),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: hairline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand600,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: navBackground,
        selectedColor: AppColors.brand100,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        side: BorderSide(color: hairline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        modalElevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.brand100,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.brand700 : textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.brand600 : textSecondary,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand500,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: TextStyle(color: windowBackground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
