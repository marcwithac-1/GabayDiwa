import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_colors.dart';
import '../core/app_spacing.dart';
import '../core/app_typography.dart';

/// The "gabaydiwa" logo mark: brain-chip icon stacked above a two-tone
/// wordmark, exactly as laid out in Figma frame "Frame 41" (274:2457).
class GabayDiwaLogo extends StatelessWidget {
  const GabayDiwaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.logoGroupWidth,
      height: AppSpacing.logoGroupHeight,
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.iconOffsetLeft,
            top: AppSpacing.iconOffsetTop,
            child: SvgPicture.asset(
              'assets/icons/brain_chip_icon.svg',
              width: AppSpacing.iconSize,
              height: AppSpacing.iconSize,
            ),
          ),
          Positioned(
            left: 0,
            top: AppSpacing.wordmarkOffsetTop,
            child: SizedBox(
              width: AppSpacing.wordmarkWidth,
              height: AppSpacing.wordmarkHeight,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'gabay',
                      style: AppTypography.logoWordmark.copyWith(
                        color: AppColors.logoTextPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'diwa',
                      style: AppTypography.logoWordmark.copyWith(
                        color: AppColors.logoTextSecondary,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
