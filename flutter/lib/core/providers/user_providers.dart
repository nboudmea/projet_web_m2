import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final userServiceProvider = Provider<UserService>((ref) => UserService());

// ─── Élèves d'un bénévole ────────────────────────────────────────────────────

/// Stream des élèves rattachés à un bénévole en temps réel.
final benevoleElevesProvider =
    StreamProvider.family<List<AppUser>, String>((ref, benevoleId) {
  return ref.watch(userServiceProvider).getElevesOfBenevole(benevoleId);
});

// ─── Utilisateur par UID ─────────────────────────────────────────────────────

/// Stream d'un AppUser par son UID (utilisé pour afficher le bénévole d'un élève).
final userByIdProvider =
    StreamProvider.family<AppUser?, String>((ref, uid) {
  return ref.watch(userServiceProvider).getUserById(uid);
});
