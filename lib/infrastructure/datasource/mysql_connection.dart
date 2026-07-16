import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import '../../domain/domain.dart';

class MySqlDbHelper {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for desktop/web
  static final String _host = kIsWeb ? '127.0.0.1' : (defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1');
  static const int _port = 3306;
  static const String _db = 'hometask_smart';
  static const String _user = 'root';
  static const String _password = ''; // Default in XAMPP

  static ConnectionSettings get _settings => ConnectionSettings(
    host: _host,
    port: _port,
    user: _user,
    password: _password,
    db: _db,
    timeout: const Duration(seconds: 4),
  );

  // Helper to run query safely
  static Future<T> _run<T>(Future<T> Function(MySqlConnection conn) action) async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_settings);
      final result = await action(conn);
      return result;
    } catch (e) {
      debugPrint('Database error: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // --- USERS CRUD ---

  static Future<List<FamilyUser>> getUsers() async {
    return _run((conn) async {
      final results = await conn.query('SELECT username, password, role FROM users');
      return results.map((row) => FamilyUser(
        username: row['username'] as String,
        password: row['password'] as String,
        role: row['role'] as String,
      )).toList();
    });
  }

  static Future<bool> registerUser(FamilyUser user) async {
    return _run((conn) async {
      final check = await conn.query(
        'SELECT id FROM users WHERE LOWER(username) = ?',
        [user.username.trim().toLowerCase()],
      );
      if (check.isNotEmpty) return false;

      await conn.query(
        'INSERT INTO users (username, password, role) VALUES (?, ?, ?)',
        [user.username.trim(), user.password, user.role],
      );
      return true;
    });
  }

  static Future<FamilyUser?> validateLogin(String username, String password) async {
    try {
      return await _run((conn) async {
        final results = await conn.query(
          'SELECT username, password, role FROM users WHERE LOWER(username) = ? AND password = ?',
          [username.trim().toLowerCase(), password],
        );
        if (results.isEmpty) return null;
        final row = results.first;
        return FamilyUser(
          username: row['username'] as String,
          password: row['password'] as String,
          role: row['role'] as String,
        );
      });
    } catch (e) {
      // Return null or rethrow based on preference. Let's rethrow to handle in UI.
      rethrow;
    }
  }

  // --- TASKS CRUD ---

  static Future<List<HomeTask>> getTasks() async {
    return _run((conn) async {
      final results = await conn.query('SELECT id, title, assignee, time, points, is_completed FROM tasks');
      return results.map((row) => HomeTask(
        id: row['id'].toString(),
        title: row['title'] as String,
        assignee: row['assignee'] as String,
        time: row['time'] as String,
        points: row['points'] as int,
        isCompleted: (row['is_completed'] as int) == 1,
      )).toList();
    });
  }

  static Future<HomeTask> addTask(String title, String assignee, int points, String time) async {
    return _run((conn) async {
      final result = await conn.query(
        'INSERT INTO tasks (title, assignee, time, points, is_completed) VALUES (?, ?, ?, ?, 0)',
        [title, assignee, time, points],
      );
      final id = result.insertId;
      return HomeTask(
        id: id.toString(),
        title: title,
        assignee: assignee,
        time: time,
        points: points,
        isCompleted: false,
      );
    });
  }

  static Future<void> updateTaskCompletion(String id, bool isCompleted) async {
    await _run((conn) async {
      await conn.query(
        'UPDATE tasks SET is_completed = ? WHERE id = ?',
        [isCompleted ? 1 : 0, int.tryParse(id) ?? 0],
      );
    });
  }

  static Future<void> deleteTask(String id) async {
    await _run((conn) async {
      await conn.query(
        'DELETE FROM tasks WHERE id = ?',
        [int.tryParse(id) ?? 0],
      );
    });
  }

  // --- DEVICES CRUD ---

  static Future<List<SmartDevice>> getDevices() async {
    return _run((conn) async {
      final results = await conn.query('SELECT id, name, is_on, type FROM smart_devices');
      return results.map((row) => SmartDevice(
        id: row['id'].toString(),
        name: row['name'] as String,
        isOn: (row['is_on'] as int) == 1,
        type: row['type'] as String,
      )).toList();
    });
  }

  static Future<void> updateDeviceStatus(String id, bool isOn) async {
    await _run((conn) async {
      await conn.query(
        'UPDATE smart_devices SET is_on = ? WHERE id = ?',
        [isOn ? 1 : 0, int.tryParse(id) ?? 0],
      );
    });
  }
}
