import 'package:flutter/material.dart';

/// Centralized color tokens extracted from the Figma "Intro" screen
/// (node 274:2456, file 4Sg3V0SxhKpkgYSTN21O46).
class AppColors {
  AppColors._();

  /// Screen background.
  static const Color background = Color(0xFFFFFFFF);

  /// "gabay" wordmark color.
  static const Color logoTextPrimary = Color(0xFF7410C6);

  /// "diwa" wordmark color.
  static const Color logoTextSecondary = Color(0xFF8A9CE8);

  /// Icon gradient — top stop (matches logoTextPrimary).
  static const Color iconGradientStart = Color(0xFF7410C6);

  /// Icon gradient — bottom stop (matches logoTextSecondary).
  static const Color iconGradientEnd = Color(0xFF8A9CE8);

  /// Fallback body text color (unused on this screen, kept for token parity).
  static const Color textOnLight = Color(0xFF000000);
}
