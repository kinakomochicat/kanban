import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class KanbanViewModel extends ChangeNotifier {
  final prefs = SharedPreferencesAsync();
  final tasks = <Task>[];

  Future<void> load() async {
    final data = await prefs.getString('movies');
    if (data == null) return;
    tasks.clear();
    for (final t in jsonDecode(data)) {
      tasks.add(Task(t['title'], t['status'], t['star']));
    }
  }

  Future<void> save() async {
    notifyListeners();
    final data = [
      for (final t in tasks) {'title': t.title, 'status': t.status, 'star': t.star}
    ];
    await prefs.setString('movies', jsonEncode(data));
  }

  void add(String text) {
    final title = text.trim();
    if (title.isEmpty) return;

    tasks.add(Task(text));
    save();
  }

  void move(Task t, int status) {
    t.status = status;
    save();
  }

  void rename(Task t, String text) {
    final title = text.trim();
    if (title.isEmpty) return;

    t.title = text;
    save();
  }

  void remove(Task t) {
    tasks.remove(t);
    save();
  }

  void rate(Task t, int star) {
    t.star = star;
    save();
  }

  // 検索
  List<Task> search(String keyword) {
    List<Task> result = [];

    for (var t in tasks) {
      if (t.title.contains(keyword)) {
        result.add(t);
      }
    }

    return result;
  }

  // ランダム
  Task? pickRandom() {
    List<Task> candidates = [];

    for (var t in tasks) {
      if (t.status != 2) {
        candidates.add(t);
      }
    }

    if (candidates.isEmpty) return null;

    final index = Random().nextInt(candidates.length);
    return candidates[index];
  }

  // 映画カウント
  int watchedCount() {
    int count = 0;

    for (var t in tasks) {
      if (t.status == 2) {
        count++;
      }
    }

    return count;
  }
}