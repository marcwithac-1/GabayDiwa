import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography tokens.
///
/// NOTE: The Figma design specifies the custom font family "Mango:Regular",
/// which is a licensed/custom font not available in this environment.
/// "Fredoka" (Google Fonts) is used as the closest publicly-available
/// rounded-display substitute. Replace [logoWordmark] with the real
/// "Mango" font family once the licensed font asset is added to the project.
class AppTypography {
  AppTypography._();

  /// Wordmark style used for the "gabaydiwa" logo text on the intro screen.
  /// Figma spec: font-size 33.7, weight regular, line-height 100.005%.
  static TextStyle logoWordmark = GoogleFonts.fredoka(
    fontSize: 33.7,
    fontWeight: FontWeight.w400,
    height: 1.0000499725341797,
    letterSpacing: 0,
  );
}
