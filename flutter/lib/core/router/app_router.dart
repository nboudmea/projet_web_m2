import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../../features/login/screens/login_screen.dart';
import '../../features/registration/screens/registration_screen.dart';
import '../../features/dashboard/eleve/screens/eleve_dashboard_screen.dart';
import '../../features/dashboard/benevole/screens/benevole_dashboard_screen.dart';

// ─── RouterNotifier (ChangeNotifier) ─────────────────────────────────────────

/// Notifie GoRouter lorsque l'état d'authentification change.
/// Miroir des guards Angular : [authGuard], [publicGuard], [roleRedirectGuard].
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Écoute l'état Firebase Auth brut
    _ref.listen(authStateProvider, (prev, next) => notifyListeners());
    // Écoute l'AppUser enrichi (pour la redirection par rôle)
    _ref.listen(currentUserProvider, (prev, next) => notifyListeners());
  }

  final Ref _ref;

  /// Logique de redirection — miroir des trois guards Angular.
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final userState = _ref.read(currentUserProvider);

    // En cours de chargement : on ne redirige pas
    if (authState.isLoading) return null;

    final isLoggedIn = authState.asData?.value != null;
    final location = state.matchedLocation;
    final isPublicRoute =
        location == '/login' || location == '/register';

    // --- PUBLIC GUARD : redirige vers /dashboard si déjà connecté ---
    if (isLoggedIn && isPublicRoute) return '/dashboard';

    // --- AUTH GUARD : redirige vers /login si non connecté ---
    if (!isLoggedIn && !isPublicRoute) return '/login';

    // --- ROLE REDIRECT GUARD : depuis /dashboard, redirige selon le rôle ---
    if (isLoggedIn && location == '/dashboard') {
      if (userState.isLoading) return null;
      final appUser = userState.asData?.value;
      if (appUser == null) return null;
      return appUser.isBenevole ? '/dashboard/benevole' : '/dashboard/eleve';
    }

    return null;
  }
}

// ─── Router provider ──────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/login',
    routes: [
      // ── Routes publiques ──────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),

      // ── Route pivot /dashboard → redirigée par rôle ───────────────────────
      GoRoute(
        path: '/dashboard',
        // Cet écran n'est jamais affiché : le redirect du notifier prend le relais.
        // On affiche un loader pendant la résolution du rôle.
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        routes: [
          // Dashboard élève
          GoRoute(
            path: 'eleve',
            builder: (context, state) => const EleveDashboardScreen(),
          ),
          // Dashboard bénévole
          GoRoute(
            path: 'benevole',
            builder: (context, state) => const BenevoleDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});
