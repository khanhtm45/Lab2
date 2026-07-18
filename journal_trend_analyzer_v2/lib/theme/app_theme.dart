import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium academic analytics theme — Material Design 3
/// Color palette per design spec
class AppColors {
  // Brand
  static const primary   = Color(0xFF2563EB); // Deep Blue
  static const secondary = Color(0xFF06B6D4); // Cyan
  static const accent    = Color(0xFF7C3AED); // Violet

  // Background / surface
  static const background  = Color(0xFFF8FAFC);
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F9);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);

  // Text
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary  = Color(0xFF94A3B8);

  // Border / divider
  static const border  = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE2E8F0);

  // Legacy aliases kept for widget compatibility
  static const analyticsTeal  = secondary;
  static const citationAmber  = warning;
  static const navInactive    = textTertiary;
  static const badge          = primary;

  static const chartColors = [
    primary,
    secondary,
    accent,
    warning,
    success,
    error,
    Color(0xFF6366F1),
    Color(0xFF0D9488),
  ];
}

/// Theme-aware palette for light and dark mode.
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color citation;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color error;
  final Color success;
  final Color warning;
  final bool isDark;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.citation,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.error,
    required this.success,
    required this.warning,
    required this.isDark,
  });

  static const light = AppPalette(
    background:       AppColors.background,
    surface:          AppColors.surface,
    surfaceMuted:     AppColors.surfaceMuted,
    primary:          AppColors.primary,
    secondary:        AppColors.secondary,
    accent:           AppColors.accent,
    textPrimary:      AppColors.textPrimary,
    textSecondary:    AppColors.textSecondary,
    textTertiary:     AppColors.textTertiary,
    border:           AppColors.border,
    citation:         AppColors.warning,
    skeletonBase:     Color(0xFFE2E8F0),
    skeletonHighlight:Color(0xFFF8FAFC),
    error:            AppColors.error,
    success:          AppColors.success,
    warning:          AppColors.warning,
    isDark:           false,
  );

  static const dark = AppPalette(
    background:       Color(0xFF0F172A),
    surface:          Color(0xFF1E293B),
    surfaceMuted:     Color(0xFF334155),
    primary:          Color(0xFF818CF8),
    secondary:        Color(0xFF22D3EE),
    accent:           Color(0xFFA78BFA),
    textPrimary:      Color(0xFFF8FAFC),
    textSecondary:    Color(0xFFCBD5E1),
    textTertiary:     Color(0xFF94A3B8),
    border:           Color(0xFF334155),
    citation:         Color(0xFFFBBF24),
    skeletonBase:     Color(0xFF334155),
    skeletonHighlight:Color(0xFF475569),
    error:            Color(0xFFF87171),
    success:          Color(0xFF4ADE80),
    warning:          Color(0xFFFBBF24),
    isDark:           true,
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : AppColors.textPrimary.withValues(alpha: 0.06),
          blurRadius: isDark ? 20 : 16,
          offset: Offset(0, isDark ? 6 : 4),
        ),
      ];
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => AppPalette.of(this);
}

class AppDimens {
  static const cardRadius   = 20.0; // Updated to 20px per design spec
  static const pagePadding  = 20.0;
  static const innerRadius  = 12.0;
  static const chipRadius   = 24.0;

  static List<BoxShadow> get cardShadow => AppPalette.light.cardShadow;
  static List<BoxShadow> cardShadowFor(BuildContext context) =>
      context.palette.cardShadow;
}

List<Color> chartSeriesColors(AppPalette palette) => [
      palette.primary,
      palette.secondary,
      palette.accent,
      palette.citation,
      const Color(0xFF22C55E),
      const Color(0xFFEF4444),
      const Color(0xFF6366F1),
      const Color(0xFF0D9488),
    ];

TextTheme _buildTextTheme(Color textPrimary, Color textSecondary) {
  return TextTheme(
    displayLarge: GoogleFonts.beVietnamPro(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.beVietnamPro(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.4,
    ),
    headlineMedium: GoogleFonts.beVietnamPro(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.3,
    ),
    headlineSmall: GoogleFonts.beVietnamPro(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.2,
    ),
    titleMedium: GoogleFonts.beVietnamPro(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleSmall: GoogleFonts.beVietnamPro(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.45,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
  );
}

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? AppPalette.dark : AppPalette.light;

  final colorScheme = ColorScheme(
    brightness:  brightness,
    primary:     palette.primary,
    onPrimary:   isDark ? const Color(0xFF0F172A) : Colors.white,
    secondary:   palette.secondary,
    onSecondary: isDark ? const Color(0xFF0F172A) : Colors.white,
    tertiary:    palette.accent,
    onTertiary:  Colors.white,
    surface:     palette.surface,
    onSurface:   palette.textPrimary,
    error:       palette.error,
    onError:     Colors.white,
    outline:     palette.border,
  );

  final textTheme =
      _buildTextTheme(palette.textPrimary, palette.textSecondary);

  return ThemeData(
    useMaterial3: true,
    brightness:   brightness,
    scaffoldBackgroundColor: palette.background,
    colorScheme:  colorScheme,
    textTheme:    textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor:        palette.background,
      foregroundColor:        palette.textPrimary,
      elevation:              0,
      scrolledUnderElevation: 0,
      centerTitle:            false,
      titleTextStyle:         textTheme.titleMedium,
    ),
    cardTheme: CardThemeData(
      color:     palette.surface,
      elevation: 0,
      margin:    EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        side: BorderSide(color: palette.border.withValues(alpha: 0.6)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      indicatorColor:  palette.primary.withValues(alpha: 0.14),
      height:          68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.beVietnamPro(
          fontSize:   11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color:      selected ? palette.primary : AppColors.navInactive,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? palette.primary : AppColors.navInactive,
          size:  22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: palette.surface,
      hintStyle: GoogleFonts.inter(color: palette.textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        borderSide: BorderSide(color: palette.primary, width: 1.5),
      ),
    ),
    dividerColor: palette.border,
    chipTheme: ChipThemeData(
      backgroundColor:  palette.surface,
      selectedColor:    palette.secondary.withValues(alpha: 0.14),
      disabledColor:    palette.surfaceMuted,
      checkmarkColor:   palette.secondary,
      side:             BorderSide(color: palette.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize:   12,
        fontWeight: FontWeight.w500,
        color:      palette.textSecondary,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize:   12,
        fontWeight: FontWeight.w600,
        color:      palette.secondary,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? palette.primary.withValues(alpha: 0.14)
                : palette.surface),
        side: WidgetStateProperty.all(BorderSide(color: palette.border)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle:
            GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.textPrimary,
        side:            BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        textStyle:
            GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor:           palette.primary,
      unselectedLabelColor: AppColors.navInactive,
      indicatorColor:       palette.primary,
      labelStyle: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w500, fontSize: 13),
      dividerColor: palette.border,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
    ),
  );
}
