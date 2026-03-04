import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// Service utilisateur — miroir de UserService Angular.
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Élèves rattachés à un bénévole (benevoleId == benevoleId)
  Stream<List<AppUser>> getElevesOfBenevole(String benevoleId) {
    return _db
        .collection('users')
        .where('benevoleId', isEqualTo: benevoleId)
        .snapshots()
        .map((snap) => snap.docs
            .map(AppUser.fromDoc)
            .toList());
  }

  /// Retourne un utilisateur par son UID en temps réel.
  Stream<AppUser?> getUserById(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? AppUser.fromDoc(snap) : null);
  }
}
