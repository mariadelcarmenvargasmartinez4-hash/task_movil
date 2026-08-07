import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
  final double blur;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24.0,
    this.borderColor,
    this.shadow,
    this.blur = 20.0, // Increased blur for better effect
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cardGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppTheme.borderGlass,
              width: 1.0, // Thinner border looks better on glass
            ),
            boxShadow: shadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
