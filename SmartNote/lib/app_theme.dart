import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Modern Vibrant Palette - Light Mode
  static const Color primaryColor = Color(0xFF7BA6FF); // Sky Blue
  static const Color secondaryColor = Color(0xFF7DDFFF); // Light Cyan
  static const Color accentColor = Color(0xFFFFA07A); // Light Salmon
  static const Color successColor = Color(0xFF32CD32); // Lime Green
  static const Color warningColor = Color(0xFFFFD700); // Gold

  // Light Mode Colors - Soft Gradient Inspired
  static const Color lightBackground = Color(0xFFF0F8FF); // Alice Blue
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightCardBg = Color(0xFFF5FAFF); // Slightly blue-tinted
  static const Color lightTextPrimary = Color(0xFF1F2937); // Dark gray
  static const Color lightTextSecondary = Color(0xFF6B7280); // Medium gray
  static const Color lightBorder = Color(0xFFD6E6FF); // Light blue tint
  static const Color lightHover = Color(0xFFE6F4FF);

  // 🌙 Dark Mode Palette - Deep Blue Sea
  static const Color darkBackground = Color(0xFF0A192F); // Deep Navy
  static const Color darkSurface = Color(0xFF172A46); // Lighter Navy
  static const Color darkCardBg = Color(0xFF1E3A5F); // Elevated Navy
  static const Color darkTextPrimary = Color(0xFFF0F8FF); // Alice Blue
  static const Color darkTextSecondary = Color(0xFFB0C4DE); // Light Steel Blue
  static const Color darkBorder = Color(0xFF2E4B72);
  static const Color darkHover = Color(0xFF254061);

  // 🎯 Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7BA6FF), Color(0xFF7DDFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7DDFFF), Color(0xFFFFA07A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF32CD32), Color(0xFF2E8B57)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌅 Background Gradients for more visual interest
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF0F8FF), Color(0xFFE6F4FF), Color(0xFFD6E6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0A192F), Color(0xFF172A46), Color(0xFF1E3A5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // 🎨 Mesh Gradient Overlay (use as decoration overlay)
  static BoxDecoration meshGradientOverlay({required bool isDark}) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: isDark
            ? [
                Color(0xFF7BA6FF).withOpacity(0.03),
                Colors.transparent,
              ]
            : [
                Color(0xFF7DDFFF).withOpacity(0.04),
                Colors.transparent,
              ],
      ),
    );
  }

  // 🖋 Modern Font Stack - Inter for clean, modern look
  static TextTheme _buildTextTheme(Color textColor, Color secondaryTextColor) {
    return GoogleFonts.interTextTheme()
        .apply(
          bodyColor: textColor,
          displayColor: textColor,
        )
        .copyWith(
          // Display styles
          displayLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.inter(
            color: textColor,
            fontSize: 45,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: GoogleFonts.inter(
            color: textColor,
            fontSize: 36,
            fontWeight: FontWeight.w600,
          ),

          // Headline styles
          headlineLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.inter(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: GoogleFonts.inter(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),

          // Title styles
          titleLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.inter(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),

          // Body styles
          bodyLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),

          // Label styles
          labelLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            color: secondaryTextColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        );
  }

  // 🌞 Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.inter().fontFamily,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      background: lightBackground,
      onBackground: lightTextPrimary,
      outline: lightBorder,
      surfaceVariant: lightHover,
      onSurfaceVariant: lightTextSecondary,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      titleTextStyle: GoogleFonts.inter(
        color: lightTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(
        color: lightTextPrimary,
        size: 24,
      ),
    ),

    // Card Theme

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.inter(
        color: lightTextSecondary,
        fontSize: 14,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: lightHover,
      selectedColor: primaryColor.withOpacity(0.1),
      labelStyle: GoogleFonts.inter(
        color: lightTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: lightBorder),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
      space: 1,
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightTextPrimary,
      contentTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary),
  );

  // 🌙 Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.inter().fontFamily,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: Color(0xFFF87171),
      onError: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      background: darkBackground,
      onBackground: darkTextPrimary,
      outline: darkBorder,
      surfaceVariant: darkHover,
      onSurfaceVariant: darkTextSecondary,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: darkTextPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(
        color: darkTextPrimary,
        size: 24,
      ),
    ),

    // Card Theme

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.inter(
        color: darkTextSecondary,
        fontSize: 14,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: darkHover,
      selectedColor: primaryColor.withOpacity(0.2),
      labelStyle: GoogleFonts.inter(
        color: darkTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: darkBorder),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
      space: 1,
    ),

    // Dialog Theme

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkTextPrimary,
      contentTextStyle: GoogleFonts.inter(
        color: darkBackground,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
  );

  // 🎨 Helper method to create gradient containers
  static BoxDecoration gradientDecoration({
    required Gradient gradient,
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null ? Border.all(color: borderColor) : null,
    );
  }

  // 🌟 Glass morphism effect
  static BoxDecoration glassMorphism({
    required bool isDark,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // 🎨 Animated Gradient Background Widget (use as Scaffold wrapper)
  static Widget gradientBackground({
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? darkBackgroundGradient : lightBackgroundGradient,
      ),
      child: child,
    );
  }

  // ✨ Floating Orb Decoration (add subtle floating color orbs)
  static List<Widget> floatingOrbs({required bool isDark}) {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isDark ? Color(0xFF7BA6FF) : Color(0xFF7DDFFF))
                    .withOpacity(isDark ? 0.1 : 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -150,
        left: -100,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isDark ? Color(0xFFFFA07A) : Color(0xFF7BA6FF))
                    .withOpacity(isDark ? 0.08 : 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }
}