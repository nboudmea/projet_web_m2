import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'benevole_accueil_screen.dart';
import 'benevole_taches_screen.dart';

/// Shell de navigation du bénévole.
/// Fournit la bottom NavigationBar + IndexedStack (Accueil / Tâches).
class BenevoleDashboardScreen extends ConsumerStatefulWidget {
  const BenevoleDashboardScreen({super.key});

  @override
  ConsumerState<BenevoleDashboardScreen> createState() =>
      _BenevoleDashboardScreenState();
}

class _BenevoleDashboardScreenState
    extends ConsumerState<BenevoleDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        backgroundColor: AppColors.foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'Learn'),
              TextSpan(
                text: '@',
                style: TextStyle(color: AppColors.accent),
              ),
              TextSpan(text: 'Home'),
            ],
          ),
        ),
        actions: [
          Semantics(
            label: 'Se déconnecter',
            child: IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: Color(0x8CFFFFFF)),
              tooltip: 'Se déconnecter',
              onPressed: () async {
                await ref.read(authServiceProvider).logout();
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BenevoleAccueilScreen(
            onGoToTaches: () => setState(() => _currentIndex = 1),
          ),
          const BenevoleTachesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box_rounded),
            label: 'Tâches',
          ),
        ],
      ),
    );
  }
}

// ─── Stub conservé pour compatibilité fichier ────────────────────────────────
// ignore: unused_element
class _DashboardPlaceholderCard extends StatelessWidget {
  const _DashboardPlaceholderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(26),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
