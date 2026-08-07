import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor; // Not used in Neumorphism typically, kept for compatibility
  final List<BoxShadow>? shadow;
  final double blur; // Used for neumorphic blur radius
  final Color? backgroundColor;
  final bool isConcave;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24.0,
    this.borderColor,
    this.shadow,
    this.blur = 20.0,
    this.backgroundColor,
    this.isConcave = false, // Neumorphic addition
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.neoBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow ??
            [
              // Dark shadow (bottom right)
              BoxShadow(
                color: AppTheme.neoShadowDark,
                blurRadius: blur,
                offset: Offset(blur / 2, blur / 2),
              ),
              // Light shadow (top left)
              BoxShadow(
                color: AppTheme.neoShadowLight,
                blurRadius: blur,
                offset: Offset(-blur / 2, -blur / 2),
              ),
            ],
      ),
      child: child,
    );
  }
}
