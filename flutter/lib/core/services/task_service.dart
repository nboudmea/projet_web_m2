import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

/// Service de gestion des tâches — miroir de TaskService Angular.
class TaskService {
  TaskService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Lecture temps réel ───────────────────────────────────────────────────

  /// Tâches assignées à un élève (assigneeId == eleveId)
  Stream<List<Task>> getTasksEleve(String eleveId) {
    return _db
        .collection('tasks')
        .where('assigneeId', isEqualTo: eleveId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Task.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  /// Tâches créées par un bénévole (createurId == benevoleId)
  Stream<List<Task>> getTasksBenevole(String benevoleId) {
    return _db
        .collection('tasks')
        .where('createurId', isEqualTo: benevoleId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Task.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────

  Future<void> createTask(Task task) async {
    await _db.collection('tasks').add({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleTask(String taskId, {required bool terminee}) async {
    await _db.collection('tasks').doc(taskId).update({'terminee': terminee});
  }
}
