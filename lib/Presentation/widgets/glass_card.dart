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
  final bool isConcave;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20.0,
    this.borderColor,
    this.shadow,
    this.blur = 0.0, // No blur for game style
    this.backgroundColor,
    this.isConcave = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.gameBorder,
          width: 3.0,
        ),
        boxShadow: shadow ??
            [
              // Hard drop shadow
              BoxShadow(
                color: AppTheme.gameBorder,
                blurRadius: 0,
                offset: const Offset(4, 6),
              ),
            ],
      ),
      child: child,
    );
  }
}

