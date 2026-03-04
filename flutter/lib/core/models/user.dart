import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle utilisateur applicatif (élève ou bénévole).
/// Miroir de l'interface [User] Angular.
class AppUser {
  const AppUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.photoUrl,
    this.benevoleId,
  });

  final String id;
  final String nom;
  final String prenom;
  final String email;

  /// 'eleve' ou 'benevole'
  final String role;

  final String? photoUrl;

  /// Renseigné sur le document d'un élève : UID du bénévole qui le suit
  final String? benevoleId;

  bool get isBenevole => role == 'benevole';
  bool get isEleve => role == 'eleve';

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      nom: data['nom'] as String? ?? '',
      prenom: data['prenom'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'eleve',
      photoUrl: data['photoUrl'] as String?,
      benevoleId: data['benevoleId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'role': role,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (benevoleId != null) 'benevoleId': benevoleId,
      };

  AppUser copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? role,
    String? photoUrl,
    String? benevoleId,
  }) {
    return AppUser(
      id: id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      benevoleId: benevoleId ?? this.benevoleId,
    );
  }

  @override
  String toString() => 'AppUser(id: $id, email: $email, role: $role)';
}
