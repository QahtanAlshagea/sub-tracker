import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';

/// Luxury ambient mesh background widget that renders subtle gradient depth
/// behind app screens while preserving strict WCAG 2.1 AA readability.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // Solid theme base
        Container(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        ),

        // Ambient top-forward glowing radial orb
        Positioned(
          top: -120,
          right: -80,
          width: 380,
          height: 380,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0x334F46E5) // Soft deep indigo glow
                        : const Color(0x35A5B4FC), // Soft pastel indigo wash
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ),
        ),

        // Ambient bottom-reverse soft emerald accent orb
        Positioned(
          bottom: -100,
          left: -80,
          width: 320,
          height: 320,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0x1810B981) // Gentle emerald hint
                        : const Color(0x20A7F3D0), // Gentle emerald tint
                    const Color(0x00000000),
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
          ),
        ),

        // Child Content
        child,
      ],
    );
  }
}
