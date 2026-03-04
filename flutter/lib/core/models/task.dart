import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle tâche — miroir de l'interface Task Angular.
class Task {
  const Task({
    required this.id,
    required this.titre,
    required this.assigneeId,
    required this.createurId,
    required this.terminee,
    this.description,
    this.dateEcheance,
  });

  final String id;
  final String titre;
  final String? description;

  /// UID de l'élève concerné
  final String assigneeId;

  /// UID du créateur (élève ou bénévole)
  final String createurId;

  final DateTime? dateEcheance;
  final bool terminee;

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    DateTime? echeance;
    final raw = data['dateEcheance'];
    if (raw is Timestamp) {
      echeance = raw.toDate();
    }
    return Task(
      id: doc.id,
      titre: data['titre'] as String? ?? '',
      description: data['description'] as String?,
      assigneeId: data['assigneeId'] as String? ?? '',
      createurId: data['createurId'] as String? ?? '',
      terminee: data['terminee'] as bool? ?? false,
      dateEcheance: echeance,
    );
  }

  Map<String, dynamic> toMap() => {
        'titre': titre,
        if (description != null) 'description': description,
        'assigneeId': assigneeId,
        'createurId': createurId,
        'terminee': terminee,
        if (dateEcheance != null)
          'dateEcheance': Timestamp.fromDate(dateEcheance!),
      };

  Task copyWith({
    String? titre,
    String? description,
    String? assigneeId,
    String? createurId,
    bool? terminee,
    DateTime? dateEcheance,
  }) {
    return Task(
      id: id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      createurId: createurId ?? this.createurId,
      terminee: terminee ?? this.terminee,
      dateEcheance: dateEcheance ?? this.dateEcheance,
    );
  }
}
