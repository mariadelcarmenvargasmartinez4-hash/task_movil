import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class DeberesView extends StatelessWidget {
  final List<HomeTask> tasks;
  final ValueChanged<HomeTask> onTaskCompleted;
  final bool isParent;
  final String? childName;
  final Function(String title, String assignee, int points, String time, String date, String priority)? onTaskAdded;
  final ValueChanged<String>? onTaskDeleted;
  final ValueChanged<HomeTask>? onTaskUpdated;
  final List<String> familyMembers;

  const DeberesView({
    super.key,
    required this.tasks,
    required this.onTaskCompleted,
    required this.isParent,
    this.childName,
    this.onTaskAdded,
    this.onTaskDeleted,
    this.onTaskUpdated,
    this.familyMembers = const [],
  });

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    
    final assignees = familyMembers.isNotEmpty ? familyMembers : ['Carlos', 'Ana', 'Papá', 'Mamá'];
    String assignee = assignees.contains('Carlos') ? 'Carlos' : assignees.first; // Default assignee option
    int points = 10; // Default points option
    String time = '8:00 PM'; // Default time option
    String priority = 'media'; // Default priority
    DateTime selectedDate = DateTime(2026, 5, 27); // Default to calendar active month

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
                  color: AppTheme.textLight,
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
                      const SizedBox(height: 16),

                      // Priority Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Prioridad'),
                        items: const [
                          DropdownMenuItem(value: 'alta', child: Text('Alta')),
                          DropdownMenuItem(value: 'media', child: Text('Media')),
                          DropdownMenuItem(value: 'baja', child: Text('Baja')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => priority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Picker Field
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Fecha: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month, color: AppTheme.glassCyan),
                            label: const Text('Elegir', style: TextStyle(color: AppTheme.glassCyan)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2026, 1, 1),
                                lastDate: DateTime(2026, 12, 31),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ],
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
                      final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                      onTaskAdded?.call(title, assignee, points, time, dateStr, priority);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.glassCyan,
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

  void _showEditTaskDialog(BuildContext context, HomeTask task) {
    final formKey = GlobalKey<FormState>();
    String title = task.title;
    String assignee = task.assignee;
    int points = task.points;
    String time = task.time;
    String priority = task.priority;
    DateTime selectedDate;
    try {
      selectedDate = DateTime.parse(task.date);
    } catch (_) {
      selectedDate = DateTime(2026, 5, 27);
    }

    final assignees = familyMembers.isNotEmpty ? List<String>.from(familyMembers) : ['Carlos', 'Ana', 'Papá', 'Mamá'];
    // Ensure current assignee is in dropdown options
    if (!assignees.contains(assignee)) {
      assignees.add(assignee);
    }

    final pointOptions = [5, 10, 15, 20, 25];
    if (!pointOptions.contains(points)) {
      pointOptions.add(points);
      pointOptions.sort();
    }

    final times = ['6:00 AM', '8:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM', '8:00 PM', '9:00 PM'];
    if (!times.contains(time)) {
      times.add(time);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Editar Tarea',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
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
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: 'Título de la tarea',
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
                      const SizedBox(height: 16),

                      // Priority Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Prioridad'),
                        items: const [
                          DropdownMenuItem(value: 'alta', child: Text('Alta')),
                          DropdownMenuItem(value: 'media', child: Text('Media')),
                          DropdownMenuItem(value: 'baja', child: Text('Baja')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => priority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Picker Field
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Fecha: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_month, color: AppTheme.glassCyan),
                            label: const Text('Elegir', style: TextStyle(color: AppTheme.glassCyan)),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2026, 1, 1),
                                lastDate: DateTime(2026, 12, 31),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ],
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
                      final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                      onTaskUpdated?.call(task.copyWith(
                        title: title,
                        assignee: assignee,
                        points: points,
                        time: time,
                        date: dateStr,
                        priority: priority,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.glassCyan,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
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
      final matchesRole = isParent || (childName != null && t.assignee.trim().toLowerCase() == childName!.trim().toLowerCase());
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
                  color: AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              if (isParent)
                TextButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.glassCyan),
                  label: const Text(
                    'Crear Tarea',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.glassCyan,
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
      backgroundColor: Colors.transparent, // Default to app theme in GlassCard
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
                  color: AppTheme.borderGlass,
                  width: 2,
                ),
                color: Colors.transparent,
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
                    color: AppTheme.textLight,
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
                    const SizedBox(width: 8),
                    _buildPriorityPill(task.priority),
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
                  color: AppTheme.glassCyan,
                ),
              ),
              if (isParent) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showEditTaskDialog(context, task),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.glassCyan,
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
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

  Widget _buildPriorityPill(String priority) {
    Color bgColor;
    Color textColor;
    String label;

    switch (priority.toLowerCase()) {
      case 'alta':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFEF4444);
        label = 'Alta';
        break;
      case 'baja':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF22C55E);
        label = 'Baja';
        break;
      case 'media':
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        label = 'Media';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
