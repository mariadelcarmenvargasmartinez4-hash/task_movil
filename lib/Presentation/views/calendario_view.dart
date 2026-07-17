import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class CalendarioView extends StatefulWidget {
  final List<HomeTask> tasks;

  const CalendarioView({super.key, required this.tasks});

  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  int _selectedDay = 27;

  // Map task to calendar days mathematically between Mayo 21st and Mayo 31st
  int _getTaskDay(HomeTask task) {
    final idVal = int.tryParse(task.id) ?? task.id.hashCode;
    return (idVal % 11).abs() + 21;
  }

  @override
  Widget build(BuildContext context) {
    // Days of Mayo 2026 as per the screenshots
    final List<String> weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final List<int?> days = [
      21, 22, 23, 24, 25, 26, 27,
      28, 29, 30, 31
    ];

    // Filter tasks mapped to the selected day
    final selectedDayTasks = widget.tasks.where((t) => _getTaskDay(t) == _selectedDay).toList();

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
          
          // Calendar Grid Card
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
                // Calendar Month Title
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
                
                // Days Wrap Grid
                Wrap(
                  spacing: (MediaQuery.of(context).size.width - 48 - 40 - (32 * 7)) / 6,
                  runSpacing: 12,
                  children: days.map((day) {
                    if (day == null) {
                      return const SizedBox(width: 32, height: 32);
                    }
                    
                    final isSelected = day == _selectedDay;
                    final hasTasks = widget.tasks.any((t) => _getTaskDay(t) == day);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.electricBlue : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                            // Small indicator dot if there are tasks on this day
                            if (hasTasks && !isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Selected Day Tasks Card
          Text(
            'DEBERES DEL DÍA - MAYO $_selectedDay',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8E9CB2),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          if (selectedDayTasks.isEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              borderRadius: 20,
              backgroundColor: Colors.white,
              child: const Center(
                child: Text(
                  'No hay tareas programadas para este día.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = selectedDayTasks[index];
                return GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 20,
                  backgroundColor: Colors.white,
                  child: Row(
                    children: [
                      // Status Icon
                      Icon(
                        task.isCompleted ? Icons.check_circle : Icons.pending_actions_outlined,
                        color: task.isCompleted ? AppTheme.green : Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 14),

                      // Task Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 12, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  task.assignee,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  task.time,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Reward Points
                      Text(
                        '+${task.points} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted ? AppTheme.green : AppTheme.electricBlue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
