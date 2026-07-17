import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/domain.dart';

class MySqlDbHelper {
  // Configuración del host dinámico para conectar desde web, emulador Android o escritorio
  static final String _baseUrl = kIsWeb 
      ? 'http://localhost/hometask_api/api.php' 
      : (defaultTargetPlatform == TargetPlatform.android 
          ? 'http://10.0.2.2/hometask_api/api.php' 
          : 'http://localhost/hometask_api/api.php');

  // Método auxiliar para realizar peticiones POST a la API PHP en XAMPP
  static Future<dynamic> _post(String action, [Map<String, dynamic>? params]) async {
    final Map<String, dynamic> body = {'action': action};
    if (params != null) {
      body.addAll(params);
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          throw Exception(decoded['error']);
        }
        return decoded;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en la petición API HTTP ($action): $e');
      rethrow;
    }
  }

  // --- USERS CRUD ---

  static Future<List<FamilyUser>> getUsers() async {
    final result = await _post('get_users');
    if (result is List) {
      return result.map((item) => FamilyUser(
        name: item['name'] as String? ?? '',
        username: item['username'] as String? ?? '',
        password: '',
        role: item['role'] as String? ?? '',
      )).toList();
    }
    return [];
  }

  static Future<bool> registerUser(FamilyUser user) async {
    final result = await _post('register_user', {
      'name': user.name,
      'username': user.username,
      'password': user.password,
      'role': user.role,
    });
    if (result is Map && result.containsKey('success')) {
      return result['success'] as bool;
    }
    return false;
  }

  static Future<FamilyUser?> validateLogin(String username, String password) async {
    final result = await _post('validate_login', {
      'username': username,
      'password': password,
    });
    if (result is Map && result['success'] == true) {
      final userData = result['user'];
      return FamilyUser(
        name: userData['name'] as String? ?? '',
        username: userData['username'] as String? ?? '',
        password: userData['password'] as String? ?? '',
        role: userData['role'] as String? ?? '',
      );
    }
    return null;
  }

  // --- TASKS CRUD ---

  static Future<List<HomeTask>> getTasks() async {
    final result = await _post('get_tasks');
    if (result is List) {
      return result.map((item) => HomeTask(
        id: item['id'].toString(),
        title: item['title'] as String,
        assignee: item['assignee'] as String,
        time: item['time'] as String,
        points: item['points'] as int,
        isCompleted: item['isCompleted'] as bool,
        date: item['date'] as String? ?? '2026-05-27',
      )).toList();
    }
    return [];
  }

  static Future<HomeTask> addTask(String title, String assignee, int points, String time, String date) async {
    final result = await _post('add_task', {
      'title': title,
      'assignee': assignee,
      'points': points,
      'time': time,
      'due_date': date,
    });
    return HomeTask(
      id: result['id'].toString(),
      title: result['title'] as String,
      assignee: result['assignee'] as String,
      time: result['time'] as String,
      points: result['points'] as int,
      isCompleted: result['isCompleted'] as bool,
      date: result['date'] as String? ?? date,
    );
  }

  static Future<void> updateTaskCompletion(String id, bool isCompleted) async {
    await _post('update_task_completion', {
      'id': id,
      'is_completed': isCompleted ? 1 : 0,
    });
  }

  static Future<void> updateTask(HomeTask task) async {
    await _post('update_task', {
      'id': task.id,
      'title': task.title,
      'assignee': task.assignee,
      'points': task.points,
      'time': task.time,
      'due_date': task.date,
    });
  }

  static Future<void> deleteTask(String id) async {
    await _post('delete_task', {
      'id': id,
    });
  }

  // --- DEVICES CRUD ---

  static Future<List<SmartDevice>> getDevices() async {
    final result = await _post('get_devices');
    if (result is List) {
      return result.map((item) => SmartDevice(
        id: item['id'].toString(),
        name: item['name'] as String,
        isOn: item['isOn'] as bool,
        type: item['type'] as String,
      )).toList();
    }
    return [];
  }

  static Future<void> updateDeviceStatus(String id, bool isOn) async {
    await _post('update_device_status', {
      'id': id,
      'is_on': isOn ? 1 : 0,
    });
  }

  // --- REWARDS CRUD ---

  static Future<List<FamilyReward>> getRewards() async {
    final result = await _post('get_rewards');
    if (result is List) {
      return result.map((item) => FamilyReward(
        id: item['id'].toString(),
        title: item['title'] as String,
        points: item['points'] as int,
      )).toList();
    }
    return [];
  }

  static Future<FamilyReward> addReward(String title, int points) async {
    final result = await _post('add_reward', {
      'title': title,
      'points': points,
    });
    return FamilyReward(
      id: result['id'].toString(),
      title: result['title'] as String,
      points: result['points'] as int,
    );
  }

  static Future<void> deleteReward(String id) async {
    await _post('delete_reward', {
      'id': id,
    });
  }

  static Future<ClaimedReward> claimReward(String rewardId, String claimedBy, int points) async {
    final result = await _post('claim_reward', {
      'reward_id': rewardId,
      'claimed_by': claimedBy,
      'points': points,
    });
    return ClaimedReward(
      id: result['id'].toString(),
      rewardId: result['rewardId'].toString(),
      title: '', // Resolved locally
      claimedBy: result['claimedBy'] as String,
      points: result['points'] as int,
      claimedAt: DateTime.now().toIso8601String(),
    );
  }

  static Future<List<ClaimedReward>> getClaimedRewards() async {
    final result = await _post('get_claimed_rewards');
    if (result is List) {
      return result.map((item) => ClaimedReward(
        id: item['id'].toString(),
        rewardId: item['rewardId'].toString(),
        title: item['title'] as String,
        claimedBy: item['claimedBy'] as String,
        points: item['points'] as int,
        claimedAt: item['claimedAt'] as String,
      )).toList();
    }
    return [];
  }
}
