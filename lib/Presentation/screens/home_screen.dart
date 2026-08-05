import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/domain.dart';
import '../../config/theme/app_theme.dart';
import '../../infrastructure/datasource/mysql_connection.dart';
import '../widgets/points_header.dart';
import '../views/deberes_view.dart';
import '../views/hogar_iot_view.dart';
import '../views/calendario_view.dart';
import '../views/historial_view.dart';
import '../views/recompensas_view.dart';

class HomeScreen extends StatefulWidget {
  final int pageIndex;
  final String role;
  final String email;
  final String name;
  const HomeScreen({
    super.key,
    required this.pageIndex,
    required this.role,
    required this.email,
    required this.name,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalPoints = 180;
  Map<String, dynamic>? _currentWeather;
  bool _isLoadingWeather = false;

  String get _childDisplayName {
    if (widget.name.isNotEmpty) return widget.name;
    if (widget.email.isEmpty) return 'Carlos';
    final parts = widget.email.split('@');
    final name = parts[0];
    if (name.isEmpty) return 'Carlos';
    return name[0].toUpperCase() + name.substring(1);
  }

  // Initial tasks state based on screenshots
  late List<HomeTask> _tasks;
  
  // Initial smart devices state based on screenshots
  late List<SmartDevice> _devices;

  // Rewards state lists
  List<FamilyReward> _rewards = [];
  List<ClaimedReward> _claimedRewards = [];

  // Family users from database
  List<FamilyUser> _familyUsers = [];

  List<String> get _familyMembersList {
    if (_familyUsers.isEmpty) return [];
    return _familyUsers.map((u) => u.name.isNotEmpty ? u.name : u.username.split('@')[0]).toList();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  int _calculateTotalPoints(List<HomeTask> tasks, List<ClaimedReward> claimedRewards) {
    final isParent = widget.role == 'padre';
    if (isParent) {
      final totalEarned = tasks.where((t) => t.isCompleted).fold(0, (sum, t) => sum + t.points);
      final totalSpent = claimedRewards.fold(0, (sum, cr) => sum + cr.points);
      return totalEarned - totalSpent;
    } else {
      final name = _childDisplayName.toLowerCase();
      final email = widget.email.toLowerCase();
      final childEarned = tasks.where((t) => t.isCompleted && t.assignee.toLowerCase() == name).fold(0, (sum, t) => sum + t.points);
      final childSpent = claimedRewards.where((cr) => cr.claimedBy.toLowerCase() == email).fold(0, (sum, cr) => sum + cr.points);
      return childEarned - childSpent;
    }
  }

  @override
  void initState() {
    super.initState();
    _tasks = [
      const HomeTask(
        id: '1',
        title: 'Sacar la basura',
        assignee: 'Papá',
        time: '8:00 PM',
        points: 10,
        isCompleted: false,
      ),
      const HomeTask(
        id: '2',
        title: 'Regar las plantas',
        assignee: 'Mamá',
        time: '6:00 PM',
        points: 5,
        isCompleted: false,
      ),
      const HomeTask(
        id: '3',
        title: 'Limpiar la cocina',
        assignee: 'Carlos',
        time: '9:00 PM',
        points: 15,
        isCompleted: false,
      ),
      const HomeTask(
        id: '4',
        title: 'Pasear al perro',
        assignee: 'Ana',
        time: '4:00 PM',
        points: 10,
        isCompleted: true,
      ),
      const HomeTask(
        id: '5',
        title: 'Lavar platos',
        assignee: 'Carlos',
        time: '2:00 PM',
        points: 10,
        isCompleted: true,
      ),
    ];

    _devices = [
      const SmartDevice(
        id: '1',
        name: 'Luces Sala',
        isOn: true,
        type: 'light',
      ),
      const SmartDevice(
        id: '2',
        name: 'Termostato',
        isOn: false,
        type: 'thermostat',
      ),
      const SmartDevice(
        id: '3',
        name: 'Smart TV',
        isOn: true,
        type: 'tv',
      ),
    ];

    _rewards = [
      const FamilyReward(id: '1', title: '1 Hora de Videojuegos', points: 50),
      const FamilyReward(id: '2', title: 'Ir por un helado familiar', points: 30),
      const FamilyReward(id: '3', title: 'Tarde libre de deberes', points: 100),
      const FamilyReward(id: '4', title: 'Permiso para dormir tarde', points: 60),
      const FamilyReward(id: '5', title: 'Elegir película del domingo', points: 40),
    ];
    _claimedRewards = [];
    _familyUsers = [
      const FamilyUser(name: 'Papá', username: 'papa@hometask.com', password: '', role: 'padre'),
      const FamilyUser(name: 'Carlos', username: 'carlos@hometask.com', password: '', role: 'hijo'),
    ];

    // Asynchronously query database
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    try {
      final dbTasks = await MySqlDbHelper.getTasks();
      setState(() {
        _tasks = dbTasks;
      });
    } catch (e) {
      debugPrint('Error loading tasks from database: $e');
    }

    try {
      final dbDevices = await MySqlDbHelper.getDevices();
      setState(() {
        _devices = dbDevices;
      });
    } catch (e) {
      debugPrint('Error loading devices from database: $e');
    }

    try {
      final dbRewards = await MySqlDbHelper.getRewards();
      setState(() {
        _rewards = dbRewards;
      });
    } catch (e) {
      debugPrint('Error loading rewards from database: $e');
    }

    try {
      final dbClaimed = await MySqlDbHelper.getClaimedRewards();
      setState(() {
        _claimedRewards = dbClaimed;
      });
    } catch (e) {
      debugPrint('Error loading claimed rewards from database: $e');
    }

    try {
      final dbUsers = await MySqlDbHelper.getUsers();
      setState(() {
        _familyUsers = dbUsers;
      });
    } catch (e) {
      debugPrint('Error loading users from database: $e');
    }

    setState(() {
      _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
    });

    _syncWeather(silent: true);
  }

  Future<void> _syncWeather({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoadingWeather = true;
      });
    }

    try {
      final result = await MySqlDbHelper.syncWeather();
      setState(() {
        _currentWeather = result['weather'] as Map<String, dynamic>;
        _tasks = result['tasks'] as List<HomeTask>;
        _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
      });
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌤️ Clima del Hogar: ${_currentWeather?["description"]} (${_currentWeather?["temp"]}°C). Prioridades recalculadas!'),
            backgroundColor: AppTheme.electricBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error syncing weather: $e');
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al sincronizar el clima.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  void _showNotificationsBottomSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FutureBuilder<List<FamilyNotification>>(
          future: MySqlDbHelper.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: AppTheme.electricBlue)),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 300,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            final notifs = snapshot.data ?? [];
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historial de Alertas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (notifs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          'No hay notificaciones familiares aún.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final notif = notifs[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.electricBlue.withValues(alpha: 0.1),
                              child: const Icon(Icons.notifications_active, color: AppTheme.electricBlue),
                            ),
                            title: Text(
                              notif.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(notif.body, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                                const SizedBox(height: 4),
                                Text(
                                  notif.createdAt,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLinkWatchDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.watch_rounded, color: AppTheme.electricBlue),
              SizedBox(width: 10),
              Text('Vincular Smartwatch', style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa el código de 4 dígitos (PIN) que se muestra en la pantalla de tu reloj inteligente.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: '0000',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.electricBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final pin = textController.text.trim();
                if (pin.length != 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El PIN debe tener 4 dígitos')),
                  );
                  return;
                }

                // Guardar las referencias antes de la llamada asíncrona para evitar warnings
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                navigator.pop(); // Cerrar diálogo de PIN

                // Mostrar cargando
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.electricBlue));
                  },
                );

                final response = await MySqlDbHelper.linkPairingCode(pin, widget.email);
                
                if (mounted) {
                  navigator.pop(); // Quitar cargando (cierra el diálogo de carga al ser la ruta superior)
                  final success = response['success'] as bool? ?? false;
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(response['message'] as String? ?? 'Resultado de vinculación'),
                      backgroundColor: success ? AppTheme.green : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Vincular'),
            ),
          ],
        );
      },
    );
  }

  void _handleTaskCompleted(HomeTask task) async {
    setState(() {
      _tasks = _tasks.map((t) {
        if (t.id == task.id) {
          return t.copyWith(isCompleted: true);
        }
        return t;
      }).toList();
      _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
    });

    try {
      await MySqlDbHelper.updateTaskCompletion(task.id, true);
      MySqlDbHelper.sendFamilyNotification(
        '¡Deber Completado! 🎉',
        '${widget.name.isNotEmpty ? widget.name : _childDisplayName} completó la tarea "${task.title}" (+${task.points} pts).',
      );
    } catch (e) {
      debugPrint('Error updating task in MySQL: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  '¡"${task.title}" completada! +${task.points} pts asignados.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleDeviceToggle(SmartDevice device) async {
    final newIsOn = !device.isOn;
    setState(() {
      _devices = _devices.map((d) {
        if (d.id == device.id) {
          return d.copyWith(isOn: newIsOn);
        }
        return d;
      }).toList();
    });

    try {
      await MySqlDbHelper.updateDeviceStatus(device.id, newIsOn);
    } catch (e) {
      debugPrint('Error updating device status in MySQL: $e');
    }
  }

  void _handleTaskAdded(String title, String assignee, int points, String time, String date, [String priority = 'media']) async {
    try {
      final dbTask = await MySqlDbHelper.addTask(title, assignee, points, time, date, priority);
      setState(() {
        _tasks.add(dbTask);
        _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
      });
      MySqlDbHelper.sendFamilyNotification(
        'Nuevo Deber Asignado 📝',
        'Se asignó a $assignee la tarea "$title" por +$points pts.',
      );
    } catch (e) {
      debugPrint('MySQL offline, adding task locally: $e');
      setState(() {
        _tasks.add(
          HomeTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            assignee: assignee,
            time: time,
            points: points,
            isCompleted: false,
            date: date,
            priority: priority,
          ),
        );
        _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
      });
    }
  }

  void _handleTaskDeleted(String taskId) async {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
    });

    try {
      await MySqlDbHelper.deleteTask(taskId);
    } catch (e) {
      debugPrint('Error deleting task in MySQL: $e');
    }
  }

  void _handleTaskUpdated(HomeTask task) async {
    setState(() {
      _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
      _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
    });

    try {
      await MySqlDbHelper.updateTask(task);
    } catch (e) {
      debugPrint('Error updating task in MySQL: $e');
    }
  }

  void _handleRewardAdded(String title, int points) async {
    try {
      final newReward = await MySqlDbHelper.addReward(title, points);
      setState(() {
        _rewards.add(newReward);
      });
    } catch (e) {
      final localId = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      setState(() {
        _rewards.add(FamilyReward(id: localId, title: title, points: points));
      });
    }
  }

  void _handleRewardDeleted(String rewardId) async {
    setState(() {
      _rewards.removeWhere((r) => r.id == rewardId);
    });
    try {
      await MySqlDbHelper.deleteReward(rewardId);
    } catch (e) {
      debugPrint('Error deleting reward in MySQL: $e');
    }
  }

  void _handleRewardClaimed(String rewardId, int points) async {
    try {
      final claim = await MySqlDbHelper.claimReward(rewardId, widget.email, points);
      final reward = _rewards.firstWhere((r) => r.id == rewardId, orElse: () => const FamilyReward(id: '', title: 'Recompensa', points: 0));
      final rTitle = reward.title;
      setState(() {
        _claimedRewards.add(claim.copyWith(title: rTitle));
        _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
      });
      MySqlDbHelper.sendFamilyNotification(
        'Premio Canjeado 🎁',
        '${widget.name.isNotEmpty ? widget.name : _childDisplayName} canjeó el premio: "$rTitle" por $points pts.',
      );
    } catch (e) {
      final localId = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
      setState(() {
        _claimedRewards.add(ClaimedReward(
          id: localId,
          rewardId: rewardId,
          title: '',
          claimedBy: widget.email,
          points: points,
          claimedAt: DateTime.now().toIso8601String(),
        ));
        _totalPoints = _calculateTotalPoints(_tasks, _claimedRewards);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isParent = widget.role == 'padre';
    
    // Dynamically adjust destinations and views based on role
    final List<Widget> views;
    final List<NavigationDestination> destinations;

    if (isParent) {
      views = [
        DeberesView(
          tasks: _tasks,
          onTaskCompleted: _handleTaskCompleted,
          isParent: true,
          onTaskAdded: _handleTaskAdded,
          onTaskDeleted: _handleTaskDeleted,
          onTaskUpdated: _handleTaskUpdated,
          familyMembers: _familyMembersList,
        ),
        RecompensasView(
          rewards: _rewards,
          totalPoints: _totalPoints,
          isParent: true,
          childName: '',
          onRewardAdded: _handleRewardAdded,
          onRewardDeleted: _handleRewardDeleted,
        ),
        HogarIotView(
          devices: _devices,
          onDeviceToggle: _handleDeviceToggle,
        ),
        CalendarioView(tasks: _tasks),
        HistorialView(
          tasks: _tasks,
          isParent: true,
        ),
      ];

      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Deberes',
        ),
        NavigationDestination(
          icon: Icon(Icons.card_giftcard_outlined),
          selectedIcon: Icon(Icons.card_giftcard),
          label: 'Premios',
        ),
        NavigationDestination(
          icon: Icon(Icons.lightbulb_outline),
          selectedIcon: Icon(Icons.lightbulb),
          label: 'Hogar IoT',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Calendario',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_toggle_off),
          selectedIcon: Icon(Icons.history),
          label: 'Historial',
        ),
      ];
    } else {
      views = [
        DeberesView(
          tasks: _tasks,
          onTaskCompleted: _handleTaskCompleted,
          isParent: false,
          childName: _childDisplayName,
          familyMembers: _familyMembersList,
        ),
        RecompensasView(
          rewards: _rewards,
          totalPoints: _totalPoints,
          isParent: false,
          childName: _childDisplayName,
          onRewardClaimed: _handleRewardClaimed,
        ),
        CalendarioView(tasks: _tasks),
        HistorialView(
          tasks: _tasks,
          isParent: false,
          childName: _childDisplayName,
        ),
      ];

      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Mis Deberes',
        ),
        NavigationDestination(
          icon: Icon(Icons.card_giftcard_outlined),
          selectedIcon: Icon(Icons.card_giftcard),
          label: 'Premios',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Calendario',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_toggle_off),
          selectedIcon: Icon(Icons.history),
          label: 'Mi Historial',
        ),
      ];
    }

    // Safely clamp active index in case it was out of bounds for current role
    final int maxIndex = destinations.length - 1;
    final int activeIndex = widget.pageIndex > maxIndex ? maxIndex : widget.pageIndex;

    return Scaffold(
      body: Column(
        children: [
          // Dynamic Points Header with dynamic logout button
          PointsHeader(
            points: _totalPoints,
            onLogout: () => context.go('/login'),
            onNotificationsTap: _showNotificationsBottomSheet,
            onLinkWatch: _showLinkWatchDialog,
          ),
          if (_currentWeather != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.electricBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.electricBlue.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentWeather?['emoji'] ?? '🌤️',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clima del Hogar: ${_currentWeather?["description"]}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Temperatura actual: ${_currentWeather?["temp"]}°C • Prioridades de deberes ajustadas',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _isLoadingWeather
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.electricBlue),
                            )
                          : const Icon(Icons.sync, size: 18, color: AppTheme.electricBlue),
                      onPressed: () => _syncWeather(),
                      tooltip: 'Sincronizar Prioridades con el Clima',
                    ),
                  ],
                ),
              ),
            ),
          
          // Current View Area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: views[activeIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppTheme.electricBlue.withValues(alpha: 0.08),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.electricBlue,
                );
              }
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E9CB2),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: AppTheme.electricBlue,
                  size: 22,
                );
              }
              return const IconThemeData(
                color: Color(0xFF8E9CB2),
                size: 22,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: activeIndex,
            onDestinationSelected: (index) {
              context.go('/home/$index?role=${widget.role}&email=${widget.email}&name=${Uri.encodeComponent(widget.name)}');
            },
            backgroundColor: Colors.white,
            elevation: 0,
            height: 65,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
