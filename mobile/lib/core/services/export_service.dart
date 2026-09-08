import 'dart:convert';
import 'package:flutter/foundation.dart';

class ExportService {
  static String exportTasksToCsv(List<dynamic> tasks) {
    final StringBuffer sb = StringBuffer();
    // CSV Header
    sb.writeln('ID,Title,Description,Status,Priority,Category,Due At,Created At');

    for (var task in tasks) {
      if (task is Map) {
        final id = _escapeCsv(task['id']?.toString() ?? '');
        final title = _escapeCsv(task['title']?.toString() ?? '');
        final desc = _escapeCsv(task['description']?.toString() ?? '');
        final status = _escapeCsv(task['status']?.toString() ?? '');
        final priority = _escapeCsv(task['priority']?.toString() ?? '');
        final category = _escapeCsv(task['category']?.toString() ?? '');
        final dueAt = _escapeCsv(task['due_at']?.toString() ?? '');
        final createdAt = _escapeCsv(task['created_at']?.toString() ?? '');

        sb.writeln('$id,$title,$desc,$status,$priority,$category,$dueAt,$createdAt');
      }
    }
    return sb.toString();
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
