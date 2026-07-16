import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HistorialView extends StatelessWidget {
  final List<HomeTask> tasks;
  final bool isParent;
  final String? childName;

  const HistorialView({
    super.key,
    required this.tasks,
    required this.isParent,
    this.childName,
  });

  @override
  Widget build(BuildContext context) {
    // Filter completed tasks: show all if parent, else filter by childName
    final completedTasks = tasks.where((t) {
      final matchesRole = isParent || (childName != null && t.assignee == childName);
      return t.isCompleted && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isParent ? 'HISTORIAL DE ACTIVIDADES' : 'MI HISTORIAL DE DEBERES',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8E9CB2),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          if (completedTasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No hay tareas completadas todavía.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completedTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return _buildCompletedTaskCard(context, task);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskCard(BuildContext context, HomeTask task) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      backgroundColor: Colors.white,
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
      child: Row(
        children: [
          // Checkmark Icon
          const Icon(
            Icons.check,
            color: AppTheme.green,
            size: 20,
          ),
          const SizedBox(width: 16),
          
          // Task Info (Struck-through title)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hecho por ${task.assignee}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Points earned
          Text(
            '+${task.points} pts',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.green,
            ),
          ),
        ],
      ),
    );
  }
}
