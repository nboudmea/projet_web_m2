import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

/// Service d'authentification — miroir de AuthService Angular.
/// Toute la logique Firebase est ici, jamais dans les widgets.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ─── Streams ────────────────────────────────────────────────────────────────

  /// Stream Firebase Auth brut (User Firebase ou null)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream utilisateur applicatif avec rôle Firestore
  Stream<AppUser?> get currentAppUser$ => _auth.authStateChanges().asyncMap(
        (firebaseUser) async {
          if (firebaseUser == null) return null;
          return _fetchUser(firebaseUser.uid);
        },
      );

  // ─── Accesseurs synchrones ──────────────────────────────────────────────────

  User? get currentFirebaseUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  // ─── Actions d'authentification ─────────────────────────────────────────────

  /// Connexion email + mot de passe. Lance une [FirebaseAuthException] en cas d'erreur.
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Inscription + création du document Firestore utilisateur.
  /// Pour un élève, assigne aléatoirement un bénévole disponible (< 3 élèves).
  Future<void> register(
    String email,
    String password,
    String role,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final String? benevoleId =
        role == 'eleve' ? await _pickBenevoleAleatoire() : null;

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'benevoleId': ?benevoleId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Envoi d'un email de réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Ré-authentifie l'utilisateur avant une opération sensible.
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Met à jour l'email Firebase Auth + le champ Firestore.
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.verifyBeforeUpdateEmail(newEmail);
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'email': newEmail});
  }

  /// Met à jour le mot de passe Firebase Auth.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // ─── Helpers Firestore ──────────────────────────────────────────────────────

  /// Récupère le document AppUser depuis Firestore
  Future<AppUser?> getUser(String uid) => _fetchUser(uid);

  Future<AppUser?> _fetchUser(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromDoc(snap);
  }

  /// Sélectionne aléatoirement un bénévole ayant moins de 3 élèves.
  /// Retourne null si aucun bénévole n'est disponible.
  Future<String?> _pickBenevoleAleatoire() async {
    final bSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'benevole')
        .get();

    if (bSnapshot.docs.isEmpty) return null;

    final eSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'eleve')
        .get();

    // Comptage des élèves par bénévole
    final countMap = <String, int>{};
    for (final doc in eSnapshot.docs) {
      final bid = doc.data()['benevoleId'] as String?;
      if (bid != null) {
        countMap[bid] = (countMap[bid] ?? 0) + 1;
      }
    }

    final available = bSnapshot.docs
        .where((d) => (countMap[d.id] ?? 0) < 3)
        .toList();

    if (available.isEmpty) return null;

    available.shuffle();
    return available.first.id;
  }

  // ─── Traduction des codes Firebase ─────────────────────────────────────────

  /// Traduit un [FirebaseAuthException.code] en message lisible pour l'utilisateur.
  static String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie dans quelques minutes.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      default:
        return 'Une erreur est survenue. Réessaie.';
    }
  }
}
