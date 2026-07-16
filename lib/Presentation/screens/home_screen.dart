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

class HomeScreen extends StatefulWidget {
  final int pageIndex;
  final String role;
  const HomeScreen({super.key, required this.pageIndex, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalPoints = 180;

  // Initial tasks state based on screenshots
  late List<HomeTask> _tasks;
  
  // Initial smart devices state based on screenshots
  late List<SmartDevice> _devices;

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    // Asynchronously query database
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    try {
      final dbTasks = await MySqlDbHelper.getTasks();
      final dbDevices = await MySqlDbHelper.getDevices();
      
      int points = 0;
      for (final t in dbTasks) {
        if (t.isCompleted) points += t.points;
      }

      setState(() {
        _tasks = dbTasks;
        _devices = dbDevices;
        _totalPoints = points;
      });
    } catch (e) {
      debugPrint('Database query offline, using static lists: $e');
    }
  }

  void _handleTaskCompleted(HomeTask task) async {
    setState(() {
      _tasks = _tasks.map((t) {
        if (t.id == task.id) {
          return t.copyWith(isCompleted: true);
        }
        return t;
      }).toList();
      _totalPoints += task.points;
    });

    try {
      await MySqlDbHelper.updateTaskCompletion(task.id, true);
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

  void _handleTaskAdded(String title, String assignee, int points, String time) async {
    try {
      final dbTask = await MySqlDbHelper.addTask(title, assignee, points, time);
      setState(() {
        _tasks.add(dbTask);
      });
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
          ),
        );
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
        ),
        HogarIotView(
          devices: _devices,
          onDeviceToggle: _handleDeviceToggle,
        ),
        const CalendarioView(),
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
          childName: 'Carlos', // Standard child name for filtering
        ),
        const CalendarioView(),
        HistorialView(
          tasks: _tasks,
          isParent: false,
          childName: 'Carlos',
        ),
      ];

      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Mis Deberes',
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
              context.go('/home/$index?role=${widget.role}');
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
