import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class CalendarioView extends StatelessWidget {
  const CalendarioView({super.key});

  @override
  Widget build(BuildContext context) {
    // Days of Mayo 2026 as per the screenshot
    final List<String> weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final List<int?> days = [
      21, 22, 23, 24, 25, 26, 27,
      28, 29, 30, 31
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CALENDARIO FAMILIAR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8E9CB2),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20.0),
            borderRadius: 24,
            backgroundColor: Colors.white,
            shadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Title
                const Text(
                  'Mayo 2026',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Weekdays Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekdays.map((day) {
                    return SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E9CB2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                
                // Days Grid
                Wrap(
                  spacing: (MediaQuery.of(context).size.width - 48 - 40 - (32 * 7)) / 6,
                  runSpacing: 12,
                  children: days.map((day) {
                    if (day == null) {
                      return const SizedBox(width: 32, height: 32);
                    }
                    
                    final isSelected = day == 27;
                    
                    return GestureDetector(
                      onTap: () {
                        // Handle date press if needed
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.electricBlue : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
