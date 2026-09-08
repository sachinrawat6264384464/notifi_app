import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OfflineCacheService {
  static const _storage = FlutterSecureStorage();
  static const _cachedTasksKey = 'cached_user_tasks';
  static const _pendingActionsKey = 'pending_offline_actions';

  static Future<void> cacheTasks(List<dynamic> tasks) async {
    try {
      final jsonStr = jsonEncode(tasks);
      await _storage.write(key: _cachedTasksKey, value: jsonStr);
    } catch (e) {
      debugPrint('Failed to cache tasks offline: $e');
    }
  }

  static Future<List<dynamic>> getCachedTasks() async {
    try {
      final jsonStr = await _storage.read(key: _cachedTasksKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return jsonDecode(jsonStr) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to load cached tasks: $e');
    }
    return [];
  }

  static Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    try {
      final existingStr = await _storage.read(key: _pendingActionsKey);
      List<dynamic> actions = [];
      if (existingStr != null && existingStr.isNotEmpty) {
        actions = jsonDecode(existingStr);
      }
      actions.add(action);
      await _storage.write(key: _pendingActionsKey, value: jsonEncode(actions));
    } catch (e) {
      debugPrint('Failed to queue offline action: $e');
    }
  }

  static Future<List<dynamic>> getPendingActions() async {
    try {
      final existingStr = await _storage.read(key: _pendingActionsKey);
      if (existingStr != null && existingStr.isNotEmpty) {
        return jsonDecode(existingStr);
      }
    } catch (e) {
      debugPrint('Failed to get pending actions: $e');
    }
    return [];
  }

  static Future<void> clearPendingActions() async {
    await _storage.delete(key: _pendingActionsKey);
  }
}
