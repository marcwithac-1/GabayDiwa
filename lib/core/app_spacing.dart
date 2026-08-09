/// Layout tokens extracted from the Figma "Intro" frame (274:2456).
///
/// Figma frame: 440 x 956 (logical design size).
/// Logo group ("Frame 41", 274:2457): 188 x 161, centered on screen.
///   - Icon (274:2458): 117 x 117, positioned at x:35, y:0 within the group.
///   - Wordmark text (274:2460): 188 x 51, positioned at x:0, y:110 within
///     the group.
class AppSpacing {
  AppSpacing._();

  /// Reference design width/height (used only for documentation — layout is
  /// built with intrinsic sizes + Center so it scales correctly across
  /// phone sizes without distortion).
  static const double designWidth = 440;
  static const double designHeight = 956;

  /// Logo group dimensions.
  static const double logoGroupWidth = 188;
  static const double logoGroupHeight = 161;

  /// Icon dimensions and offset within the logo group.
  static const double iconSize = 117;
  static const double iconOffsetLeft = 35;
  static const double iconOffsetTop = 0;

  /// Wordmark dimensions and offset within the logo group.
  static const double wordmarkWidth = 188;
  static const double wordmarkHeight = 51;
  static const double wordmarkOffsetTop = 110;
}
