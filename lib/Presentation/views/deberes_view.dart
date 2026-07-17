import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class DeberesView extends StatelessWidget {
  final List<HomeTask> tasks;
  final ValueChanged<HomeTask> onTaskCompleted;
  final bool isParent;
  final String? childName;
  final Function(String title, String assignee, int points, String time)? onTaskAdded;
  final ValueChanged<String>? onTaskDeleted;
  final List<String> familyMembers;

  const DeberesView({
    super.key,
    required this.tasks,
    required this.onTaskCompleted,
    required this.isParent,
    this.childName,
    this.onTaskAdded,
    this.onTaskDeleted,
    this.familyMembers = const [],
  });

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    
    final assignees = familyMembers.isNotEmpty ? familyMembers : ['Carlos', 'Ana', 'Papá', 'Mamá'];
    String assignee = assignees.contains('Carlos') ? 'Carlos' : assignees.first; // Default assignee option
    int points = 10; // Default points option
    String time = '8:00 PM'; // Default time option

    final pointOptions = [5, 10, 15, 20, 25];
    final times = ['6:00 AM', '8:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM', '8:00 PM', '9:00 PM'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Crear Nueva Tarea',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Task Title
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Título de la tarea',
                          hintText: 'Ej. Lavar los platos',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa un título';
                          }
                          return null;
                        },
                        onSaved: (value) => title = value!.trim(),
                      ),
                      const SizedBox(height: 16),

                      // Assignee Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: assignee,
                        decoration: const InputDecoration(labelText: 'Responsable'),
                        items: assignees.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => assignee = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Points Dropdown
                      DropdownButtonFormField<int>(
                        initialValue: points,
                        decoration: const InputDecoration(labelText: 'Puntos de Recompensa'),
                        items: pointOptions.map((pts) {
                          return DropdownMenuItem(
                            value: pts,
                            child: Text('+$pts pts'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => points = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: time,
                        decoration: const InputDecoration(labelText: 'Horario Límite'),
                        items: times.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => time = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      onTaskAdded?.call(title, assignee, points, time);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.electricBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter pending tasks: show all if parent, else filter by childName
    final pendingTasks = tasks.where((t) {
      final matchesRole = isParent || (childName != null && t.assignee == childName);
      return !t.isCompleted && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isParent ? 'LISTA DE DEBERES' : 'MIS DEBERES PENDIENTES',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8E9CB2),
                  letterSpacing: 0.8,
                ),
              ),
              if (isParent)
                TextButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.electricBlue),
                  label: const Text(
                    'Crear Tarea',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (pendingTasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  '¡Todas las tareas completadas! 🎉',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = pendingTasks[index];
                return _buildTaskCard(context, task);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, HomeTask task) {
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
          // Custom Round Checkbox
          GestureDetector(
            onTap: () => onTaskCompleted(task),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD2D8E2),
                  width: 2,
                ),
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Task Info
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
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assignee,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      size: 13,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Points & Actions Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+${task.points} pts',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.electricBlue,
                ),
              ),
              if (isParent) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onTaskDeleted?.call(task.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
