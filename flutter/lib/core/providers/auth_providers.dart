import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ─── Service provider ────────────────────────────────────────────────────────

/// Provider du service d'authentification (singleton)
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Auth state (Firebase User brut) ─────────────────────────────────────────

/// Stream du FirebaseUser brut — null si non connecté
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Utilisateur applicatif enrichi (Firestore) ───────────────────────────────

/// Stream de l'AppUser avec rôle Firestore — null si non connecté
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).currentAppUser$;
});
