import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

// ─── Tasks élève ─────────────────────────────────────────────────────────────

/// Stream des tâches d'un élève en temps réel.
final eleveTasksProvider =
    StreamProvider.family<List<Task>, String>((ref, eleveId) {
  return ref.watch(taskServiceProvider).getTasksEleve(eleveId);
});

// ─── Tasks bénévole ──────────────────────────────────────────────────────────

/// Stream de toutes les tâches créées par un bénévole en temps réel.
final benevoleTasksProvider =
    StreamProvider.family<List<Task>, String>((ref, benevoleId) {
  return ref.watch(taskServiceProvider).getTasksBenevole(benevoleId);
});
