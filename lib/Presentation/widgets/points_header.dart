import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';
import 'glass_card.dart';

class PointsHeader extends StatelessWidget {
  final int points;

  const PointsHeader({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + 20,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331E50FF),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HomeTask Smart',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ecosistema Familiar Activo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Points Pill / Capsule
          GlassCard(
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            borderColor: Colors.white.withValues(alpha: 0.3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  '$points pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
