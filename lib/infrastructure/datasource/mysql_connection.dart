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
        username: item['username'] as String,
        password: item['password'] as String,
        role: item['role'] as String,
      )).toList();
    }
    return [];
  }

  static Future<bool> registerUser(FamilyUser user) async {
    final result = await _post('register_user', {
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
        username: userData['username'] as String,
        password: userData['password'] as String,
        role: userData['role'] as String,
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
      )).toList();
    }
    return [];
  }

  static Future<HomeTask> addTask(String title, String assignee, int points, String time) async {
    final result = await _post('add_task', {
      'title': title,
      'assignee': assignee,
      'points': points,
      'time': time,
    });
    return HomeTask(
      id: result['id'].toString(),
      title: result['title'] as String,
      assignee: result['assignee'] as String,
      time: result['time'] as String,
      points: result['points'] as int,
      isCompleted: result['isCompleted'] as bool,
    );
  }

  static Future<void> updateTaskCompletion(String id, bool isCompleted) async {
    await _post('update_task_completion', {
      'id': id,
      'is_completed': isCompleted ? 1 : 0,
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
}
