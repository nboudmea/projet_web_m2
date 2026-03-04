import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/providers/user_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

/// Page d'accueil du bénévole — miroir de BenevoleAccueilComponent Angular.
///
/// Affiche :
///  - 3 stats : élèves suivis, tâches en cours, tâches terminées
///  - La liste des élèves avec compteur de tâches en cours
class BenevoleAccueilScreen extends ConsumerWidget {
  const BenevoleAccueilScreen({super.key, required this.onGoToTaches});

  final VoidCallback onGoToTaches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(authStateProvider).asData?.value;
    if (firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final benevoleId = firebaseUser.uid;

    final elevesAsync = ref.watch(benevoleElevesProvider(benevoleId));
    final tasksAsync = ref.watch(benevoleTasksProvider(benevoleId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bonjour 👋',
                        style:
                            Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      "Vue d'ensemble de vos élèves et tâches",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const RoleBadge(role: 'benevole'),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stats rapides ────────────────────────────────────────────────
          elevesAsync.when(
            data: (eleves) => tasksAsync.when(
              data: (tasks) {
                final enCours = tasks.where((t) => !t.terminee).toList();
                final terminees = tasks.where((t) => t.terminee).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: '${eleves.length}',
                            label: 'Élève(s) suivi(s)',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: '${enCours.length}',
                            label: 'Tâche(s) en cours',
                            borderLeftColor:
                                AppColors.statBorderPendingBenevole,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: '${terminees.length}',
                            label: 'Tâche(s) terminée(s)',
                            borderLeftColor:
                                AppColors.statBorderDoneBenevole,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Liste des élèves ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mes élèves',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        GestureDetector(
                          onTap: onGoToTaches,
                          child: Text(
                            'Assigner une tâche →',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (eleves.isEmpty)
                      const EmptyState(
                        icon: '🎓',
                        message:
                            'Aucun élève ne vous est encore assigné.',
                      )
                    else
                      Column(
                        children: eleves
                            .map((eleve) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8),
                                  child: _EleveListItem(
                                    eleve: eleve,
                                    tachesEnCours: enCours
                                        .where((t) =>
                                            t.assigneeId == eleve.id)
                                        .length,
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur : $e'),
          ),
        ],
      ),
    );
  }
}

// ─── Item élève ───────────────────────────────────────────────────────────────

class _EleveListItem extends StatelessWidget {
  const _EleveListItem({
    required this.eleve,
    required this.tachesEnCours,
  });

  final AppUser eleve;
  final int tachesEnCours;

  @override
  Widget build(BuildContext context) {
    final nom = [eleve.prenom, eleve.nom]
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    final nomAffiche = nom.isEmpty ? eleve.email : nom;

    // Miroir Angular .eleve-card { background:#fff; border-radius:16px; padding:16px 18px; shadow }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Avatar lime
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.accent, // #D4FF3F
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              nomAffiche.isNotEmpty
                  ? nomAffiche[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.accentForeground, // #111111
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomAffiche,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  eleve.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Badge tâches — miroir Angular .eleve-badge / .eleve-badge--zero
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: tachesEnCours == 0
                  ? AppColors.taskBadgeZeroBg   // #F3F4F6 neutre
                  : AppColors.taskBadgeBg,      // #FEF3C7 ambre
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$tachesEnCours tâche(s) en cours',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tachesEnCours == 0
                    ? AppColors.mutedForeground  // #6B7280
                    : AppColors.taskBadgeFg,     // #92400E ambre
              ),
            ),
          ),
        ],
      ),
    );
  }
}
