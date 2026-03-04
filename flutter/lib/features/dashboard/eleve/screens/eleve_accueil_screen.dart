import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/providers/user_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

/// Page d'accueil de l'élève — miroir de EleveAccueilComponent Angular.
///
/// Affiche :
///  - La carte du bénévole assigné
///  - 3 stats rapides (tâches à faire / terminées / progression)
///  - Une barre de progression
///  - Les 5 premières tâches en cours
class EleveAccueilScreen extends ConsumerWidget {
  const EleveAccueilScreen({super.key, required this.onGoToTaches});

  final VoidCallback onGoToTaches;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(authStateProvider).asData?.value;
    if (firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final eleveId = firebaseUser.uid;

    final tasksAsync = ref.watch(eleveTasksProvider(eleveId));
    final userAsync = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          _PageHeader(
            title: 'Bonjour 👋',
            subtitle: 'Voici un résumé de tes dernières activités',
            trailing: const RoleBadge(role: 'eleve'),
          ),
          const SizedBox(height: 20),

          // ── Carte bénévole ───────────────────────────────────────────────
          userAsync.when(
            data: (user) => user?.benevoleId != null
                ? _BenevoleCard(benevoleId: user!.benevoleId!, ref: ref)
                : _BenevoleCardEmpty(),
            loading: () => const _BenevoleCardLoading(),
            error: (_, err) => const _BenevoleCardEmpty(),
          ),
          const SizedBox(height: 16),

          // ── Stats rapides + barre de progression ─────────────────────────
          tasksAsync.when(
            data: (tasks) {
              final enCours =
                  tasks.where((t) => !t.terminee).toList();
              final terminees =
                  tasks.where((t) => t.terminee).toList();
              final progression = tasks.isEmpty
                  ? 0
                  : ((terminees.length / tasks.length) * 100).round();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: '${enCours.length}',
                          label: 'Tâche(s) à faire',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: '${terminees.length}',
                          label: 'Tâche(s) terminée(s)',
                          borderTopColor: AppColors.statBorderDoneEleve,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: '$progression %',
                          label: 'Progression',
                          borderTopColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Barre de progression — inline, sans AppCard (miroir Angular)
                  if (tasks.isNotEmpty) ...[
                    ProgressBar(
                      value: progression / 100,
                      label: '$progression % des tâches complétées',
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tâches récentes
                  _SectionHeader(
                    title: 'Tâches à faire',
                    actionLabel: 'Voir tout →',
                    onAction: onGoToTaches,
                  ),
                  const SizedBox(height: 12),
                  if (enCours.isEmpty)
                    const EmptyState(
                      icon: '🎉',
                      message: 'Aucune tâche en attente. Bravo !',
                    )
                  else
                    Column(
                      children: enCours
                          .take(5)
                          .map((task) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _TaskPreviewItem(task: task),
                              ))
                          .toList(),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erreur : $e',
                  style:
                      const TextStyle(color: AppColors.destructive)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte bénévole ───────────────────────────────────────────────────────────

class _BenevoleCard extends ConsumerWidget {
  const _BenevoleCard({required this.benevoleId, required this.ref});
  final String benevoleId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final benevoleAsync = ref.watch(userByIdProvider(benevoleId));
    return benevoleAsync.when(
      data: (b) {
        if (b == null) return _BenevoleCardEmpty();
        final nom = [b.prenom, b.nom]
            .where((s) => s.isNotEmpty)
            .join(' ')
            .trim();
        final nomAffiche = nom.isEmpty ? b.email : nom;
        // Fond noir — miroir Angular .benevole-card { background: $dark (#111111) }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.foreground,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              // Avatar lime
              _Avatar(initial: nomAffiche.isNotEmpty
                  ? nomAffiche[0].toUpperCase()
                  : '?'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TON BÉNÉVOLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nomAffiche,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      b.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0x8CFFFFFF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Badge bénévole lime — miroir Angular .benevole-badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '👨‍🏫 Bénévole',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _BenevoleCardLoading(),
      error: (_, err) => _BenevoleCardEmpty(),
    );
  }
}

class _BenevoleCardEmpty extends StatelessWidget {
  const _BenevoleCardEmpty();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('⏳', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Aucun bénévole assigné pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenevoleCardLoading extends StatelessWidget {
  const _BenevoleCardLoading();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 12,
                    width: 80,
                    color: AppColors.border),
                const SizedBox(height: 6),
                Container(
                    height: 14, width: 140, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview tâche ────────────────────────────────────────────────────────────

class _TaskPreviewItem extends StatelessWidget {
  const _TaskPreviewItem({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    // Miroir Angular .task-item { background:#fff; border-radius:14px; padding:16px 18px; shadow }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
          // Dot lime — miroir Angular .task-dot
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.titre,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Date badge — miroir Angular .task-date { bg:#F3F4F6; radius:50px }
          if (task.dateEcheance != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                DateFormat('d MMM', 'fr').format(task.dateEcheance!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Widgets communs ─────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) ?trailing,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.accent, // lime
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.accentForeground, // #111111
        ),
      ),
    );
  }
}
