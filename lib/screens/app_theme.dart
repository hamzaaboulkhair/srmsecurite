import 'package:flutter/material.dart';

// Based on the HSL values from globals.css
class AppTheme {
  // Light Theme Colors
  static const Color background = Color.fromRGBO(255, 255, 255, 1); // 0 0% 100%
  static const Color foreground = Color.fromRGBO(36, 52, 118, 1); // 224 76% 18% (Dark Blue)

  static const Color cardBackground = Color.fromRGBO(255, 255, 255, 1); // 0 0% 100%
  static const Color cardForeground = Color.fromRGBO(36, 52, 118, 1); // 224 76% 18%
  static const Color cardBorder = Color.fromRGBO(233, 236, 242, 1); // 214.3 31.8% 91.4% (border)

  static const Color popoverBackground = Color.fromRGBO(255, 255, 255, 1); // 0 0% 100%
  static const Color popoverForeground = Color.fromRGBO(36, 52, 118, 1); // 224 76% 18%

  static const Color primary = Color.fromRGBO(34, 78, 196, 1); // 218 86% 34% (blue.shade900)
  static const Color primaryForeground = Color.fromRGBO(255, 255, 255, 1); // 0 0% 100% (White)

  static const Color secondary = Color.fromRGBO(240, 244, 250, 1); // 210 40% 96.1% (Lighter Blue)
  static const Color secondaryForeground = Color.fromRGBO(36, 52, 118, 1); // 224 76% 18%

  static const Color muted = Color.fromRGBO(240, 244, 250, 1); // 210 40% 96.1%
  static const Color mutedForeground = Color.fromRGBO(152, 161, 178, 1); // 215 20% 65.1%

  static const Color accent = Color.fromRGBO(245, 158, 11, 1); // 38 92% 51% (Orange Accent)
  static const Color accentForeground = Color.fromRGBO(255, 255, 255, 1); // 0 0% 100% (White)

  static const Color destructive = Color.fromRGBO(239, 68, 68, 1); // 0 84.2% 60.2%
  static const Color destructiveForeground = Color.fromRGBO(250, 250, 250, 1); // 0 0% 98%

  static const Color inputBorder = Color.fromRGBO(233, 236, 242, 1); // 214.3 31.8% 91.4%
  static const Color ring = Color.fromRGBO(59, 106, 225, 1); // 218 86% 44% (Slightly lighter blue for ring)

  // Chart Colors
  static const Color chart1 = primary;
  static const Color chart2 = accent;
  static const Color chart3 = Color.fromRGBO(56, 77, 90, 1); // 197 37% 24%
  static const Color chart4 = Color.fromRGBO(246, 192, 132, 1); // 43 74% 66%
  static const Color chart5 = Color.fromRGBO(241, 155, 117, 1); // 27 87% 67%

  // Radius (used for border radius)
  static const double radius = 8.0; // 0.5rem approximated
  static const double radiusS = 4.0; // 0.25rem for smaller elements like tooltips

  // Gradient background
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(235, 245, 255, 1), // from-blue-50
      Color.fromRGBO(255, 255, 255, 1), // via-white
      Color.fromRGBO(255, 247, 237, 1), // to-orange-50
    ],
  );

  // General padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(vertical: 8.0);

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
}
