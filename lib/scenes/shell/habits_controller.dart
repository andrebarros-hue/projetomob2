import "package:ciclo_core/ciclo_core.dart";
import "package:flutter/foundation.dart";

import "../../app/app_services.dart";
import "../../app/session_store.dart";

class HabitsController extends ChangeNotifier {
  HabitsController({required this.services, required this.session});

  final AppServices services;
  final SessionStore session;

  bool loading = false;
  bool ready = false;
  String? error;
  List<Habit> items = const [];
  String? busyId;

  Habit? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  int get bestStreak {
    var best = 0;
    for (final item in items) {
      if (item.streak > best) best = item.streak;
    }
    return best;
  }

  Future<void> load() async {
    final token = session.token;
    if (token == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final page = await services.habits.list(token);
      items = page.habits;
      ready = true;
      session.updateUser(page.user);
    } on ApiException catch (exception) {
      error = exception.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> toggle(Habit habit) async {
    final token = session.token;
    if (token == null || busyId != null) return null;
    busyId = habit.id;
    notifyListeners();
    try {
      final result = await services.habits.toggle(
        token,
        habit.id,
        completed: !habit.completedToday,
      );
      _upsert(result.habit);
      session.updateUser(result.user);
      return null;
    } on ApiException catch (exception) {
      return exception.message;
    } finally {
      busyId = null;
      notifyListeners();
    }
  }

  Future<Habit> save(HabitDraft draft, {String? id}) async {
    final token = session.token;
    if (token == null) {
      throw ApiException(status: 401, code: "UNAUTHORIZED", message: "Entre de novo.");
    }
    final result = id == null
        ? await services.habits.create(token, draft)
        : await services.habits.update(token, id, draft);
    _upsert(result.habit);
    session.updateUser(result.user);
    notifyListeners();
    return result.habit;
  }

  Future<void> remove(String id) async {
    final token = session.token;
    if (token == null) return;
    final user = await services.habits.delete(token, id);
    items = items.where((item) => item.id != id).toList();
    session.updateUser(user);
    notifyListeners();
  }

  Future<String?> restore() async {
    final token = session.token;
    if (token == null) return "Entre de novo.";
    try {
      await services.restoreSamples(token);
      await load();
      return null;
    } on ApiException catch (exception) {
      return exception.message;
    }
  }

  void _upsert(Habit habit) {
    final index = items.indexWhere((item) => item.id == habit.id);
    if (index < 0) {
      items = [...items, habit];
      return;
    }
    final next = [...items];
    next[index] = habit;
    items = next;
  }
}
