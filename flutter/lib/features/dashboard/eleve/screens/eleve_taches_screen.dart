import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

/// Page de gestion des tâches de l'élève — miroir exact de EleveTachesComponent Angular.
///
/// Chaque tâche est une carte individuelle (fond blanc + ombre soft).
class EleveTachesScreen extends ConsumerWidget {
  const EleveTachesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(authStateProvider).asData?.value;
    if (firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final eleveId = firebaseUser.uid;
    final tasksAsync = ref.watch(eleveTasksProvider(eleveId));

    return tasksAsync.when(
      data: (tasks) {
        final enCours = tasks.where((t) => !t.terminee).toList();
        final terminees = tasks.where((t) => t.terminee).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête ─────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes tâches',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tâches assignées par ton bénévole',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Badges compteurs — miroir Angular .counter--pending / --done
                  Row(
                    children: [
                      _CounterBadge(
                        label: '${enCours.length} à faire',
                        bgColor: const Color(0xFFFEF9C3),
                        textColor: const Color(0xFFA16207),
                      ),
                      const SizedBox(width: 8),
                      _CounterBadge(
                        label: '${terminees.length} terminée(s)',
                        bgColor: const Color(0xFFDCFCE7),
                        textColor: const Color(0xFF166534),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Section "À faire" ────────────────────────────────────────
              const _SectionTitle(label: 'À faire'),
              const SizedBox(height: 10),

              if (enCours.isEmpty)
                const EmptyState(
                  icon: '✅',
                  message: 'Toutes tes tâches sont complétées !',
                )
              else
                Column(
                  children: enCours
                      .map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(
                              task: task,
                              done: false,
                              onToggle: () => ref
                                  .read(taskServiceProvider)
                                  .toggleTask(task.id, terminee: true),
                            ),
                          ))
                      .toList(),
                ),

              // ── Section "Terminées" ───────────────────────────────────────
              if (terminees.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SectionTitle(
                  label: 'Terminées (${terminees.length})',
                  muted: true,
                ),
                const SizedBox(height: 10),
                Column(
                  children: terminees
                      .map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(
                              task: task,
                              done: true,
                              onToggle: () => ref
                                  .read(taskServiceProvider)
                                  .toggleTask(task.id, terminee: false),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Erreur : $e',
            style: const TextStyle(color: AppColors.destructive)),
      ),
    );
  }
}

// ─── Carte individuelle de tâche ──────────────────────────────────────────────
// Miroir Angular : .task-card { background:#fff; border-radius:16px; padding:16px 18px; shadow }

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.done,
    required this.onToggle,
  });

  final Task task;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Opacity(
        opacity: done ? 0.55 : 1.0,
        child: Container(
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
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Checkbox 28×28 — miroir Angular
              _Checkbox(checked: done, onTap: onToggle),
              const SizedBox(width: 14),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.titre,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : null,
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

              // Date — miroir Angular .task-badge { bg:#F3F4F6; radius:50px }
              if (task.dateEcheance != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '📅 ${DateFormat('d MMM yyyy', 'fr').format(task.dateEcheance!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Checkbox 28×28, radius 8 ─────────────────────────────────────────────────

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.onTap});
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: checked ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked ? AppColors.accent : const Color(0xFFD1D5DB),
            width: 2,
          ),
        ),
        child: checked
            ? const Icon(Icons.check,
                size: 15, color: AppColors.accentForeground)
            : null,
      ),
    );
  }
}

// ─── Titre de section UPPERCASE ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, this.muted = false});
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: muted ? AppColors.mutedForeground : AppColors.foreground,
      ),
    );
  }
}

// ─── Badge compteur (pending / done) ─────────────────────────────────────────

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
  final String label;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
