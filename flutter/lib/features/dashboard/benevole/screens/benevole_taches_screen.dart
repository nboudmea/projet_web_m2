import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/task.dart';
import '../../../../core/models/user.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/providers/user_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

/// Page de gestion des tâches du bénévole — miroir de BenevoleTachesComponent Angular.
///
/// Affiche :
///  - Chips de filtre par élève
///  - Formulaire d'assignation d'une nouvelle tâche
///  - Liste des tâches groupées par élève (filtrée)
class BenevoleTachesScreen extends ConsumerStatefulWidget {
  const BenevoleTachesScreen({super.key});

  @override
  ConsumerState<BenevoleTachesScreen> createState() =>
      _BenevoleTachesScreenState();
}

class _BenevoleTachesScreenState
    extends ConsumerState<BenevoleTachesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedEleveId;
  DateTime? _dateEcheance;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ─── Soumission ───────────────────────────────────────────────────────────

  Future<void> _submit(String benevoleId, List<AppUser> eleves) async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref.read(taskServiceProvider).createTask(Task(
            id: '',
            titre: _titreCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            assigneeId: _selectedEleveId!,
            createurId: benevoleId,
            terminee: false,
            dateEcheance: _dateEcheance,
          ));
      _titreCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _submitted = false;
        _dateEcheance = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche assignée !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr'),
    );
    if (picked != null) setState(() => _dateEcheance = picked);
  }

  void _confirmDelete(String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la tâche ?'),
        content:
            const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskServiceProvider).deleteTask(taskId);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive),
            child: const Text('Supprimer'),
          ),
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(authStateProvider).asData?.value;
    if (firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final benevoleId = firebaseUser.uid;

    final elevesAsync = ref.watch(benevoleElevesProvider(benevoleId));
    final tasksAsync = ref.watch(benevoleTasksProvider(benevoleId));

    return elevesAsync.when(
      data: (eleves) => tasksAsync.when(
        data: (tasks) => _buildContent(
            context, benevoleId, eleves, tasks),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String benevoleId,
    List<AppUser> eleves,
    List<Task> tasks,
  ) {
    // Map eleve id → eleve
    final elevesMap = {for (final e in eleves) e.id: e};

    // Filtre
    final tasksFiltrees = _selectedEleveId == null
        ? tasks
        : tasks.where((t) => t.assigneeId == _selectedEleveId).toList();

    // Groupement par élève
    final Map<String, List<Task>> grouped = {};
    for (final t in tasksFiltrees) {
      grouped.putIfAbsent(t.assigneeId, () => []).add(t);
    }

    String nomEleve(AppUser e) {
      final full = [e.prenom, e.nom]
          .where((s) => s.isNotEmpty)
          .join(' ')
          .trim();
      return full.isEmpty ? e.email : full;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ─────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tâches',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Assignez et gérez les tâches de vos élèves',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chips de filtre ──────────────────────────────────────────────
          if (eleves.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: '👥 Tous les élèves',
                    active: _selectedEleveId == null,
                    onTap: () =>
                        setState(() => _selectedEleveId = null),
                  ),
                  ...eleves.map((e) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _FilterChip(
                          label:
                              '${nomEleve(e)[0].toUpperCase()} ${nomEleve(e)}',
                          active: _selectedEleveId == e.id,
                          onTap: () =>
                              setState(() => _selectedEleveId = e.id),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Formulaire d'assignation ─────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigner une nouvelle tâche',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sélection élève
                      _FormLabel(
                          label: 'Élève',
                          required: true),
                      const SizedBox(height: 6),
                      if (eleves.isEmpty)
                        Text(
                          'Aucun élève ne vous est encore assigné.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        )
                      else
                        _EleveDropdown(
                          eleves: eleves,
                          selectedId: _selectedEleveId,
                          onChanged: (id) =>
                              setState(() => _selectedEleveId = id),
                          hasError: _submitted && _selectedEleveId == null,
                          nomEleve: nomEleve,
                        ),
                      const SizedBox(height: 14),

                      // Titre
                      _FormLabel(
                          label: 'Titre', required: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titreCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText:
                              'Ex : Exercices de mathématiques p.42',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Le titre est obligatoire.'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Description
                      _FormLabel(
                          label: 'Description',
                          required: false),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 2,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText:
                              'Précisions sur la tâche…',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Date d'échéance
                      _FormLabel(
                          label: "Date d'échéance",
                          required: false),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.input),
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.surface,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.mutedForeground),
                              const SizedBox(width: 10),
                              Text(
                                _dateEcheance != null
                                    ? DateFormat('d MMMM yyyy', 'fr')
                                        .format(_dateEcheance!)
                                    : 'Choisir une date…',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: _dateEcheance != null
                                          ? AppColors.foreground
                                          : AppColors.mutedForeground,
                                    ),
                              ),
                              const Spacer(),
                              if (_dateEcheance != null)
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _dateEcheance = null),
                                  child: const Icon(Icons.close,
                                      size: 16,
                                      color: AppColors.mutedForeground),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bouton soumettre — miroir Angular .btn-submit { radius:12px; padding:12px 28px }
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: (eleves.isEmpty || _submitting)
                              ? null
                              : () => _submit(benevoleId, eleves),
                          child: AnimatedOpacity(
                            opacity:
                                (eleves.isEmpty || _submitting) ? 0.5 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.foreground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _submitting
                                    ? 'Assignation…'
                                    : 'Assigner la tâche',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryForeground,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Liste des tâches groupées ──────────────────────────────────
          if (tasksFiltrees.isNotEmpty) ...[
            Text(
              _selectedEleveId != null && elevesMap[_selectedEleveId] != null
                  ? 'Tâches de ${nomEleve(elevesMap[_selectedEleveId]!)}'
                  : 'Toutes les tâches assignées',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...grouped.entries.map((entry) {
              final eleve = elevesMap[entry.key];
              final showHeader = _selectedEleveId == null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de groupe séparé (hors cartes) — miroir Angular .groupe-header
                    if (showHeader && eleve != null) ...
                    [
                      _GroupHeader(
                          eleve: eleve,
                          count: entry.value.length,
                          nomEleve: nomEleve),
                      const SizedBox(height: 8),
                    ],
                    // Tâches en cartes individuelles indentées si multi-élèves
                    Padding(
                      padding: EdgeInsets.only(
                          left: showHeader ? 42 : 0),
                      child: Column(
                        children: entry.value
                            .map((task) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 6),
                                  child: _BenevoleTacheItem(
                                    task: task,
                                    onToggle: () => ref
                                        .read(taskServiceProvider)
                                        .toggleTask(
                                          task.id,
                                          terminee: !task.terminee,
                                        ),
                                    onDelete: () =>
                                        _confirmDelete(task.id),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ─── Widgets local ────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.foreground : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.foreground : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active
                ? AppColors.primaryForeground
                : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}

class _EleveDropdown extends StatelessWidget {
  const _EleveDropdown({
    required this.eleves,
    required this.selectedId,
    required this.onChanged,
    required this.hasError,
    required this.nomEleve,
  });
  final List<AppUser> eleves;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool hasError;
  final String Function(AppUser) nomEleve;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? AppColors.destructive : AppColors.input,
              width: hasError ? 2 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              hint: Text(
                '— Choisir un élève —',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
              isExpanded: true,
              items: eleves
                  .map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(nomEleve(e)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            'Veuillez sélectionner un élève.',
            style: const TextStyle(
                fontSize: 12, color: AppColors.destructive),
          ),
        ],
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.destructive)),
          if (!required)
            TextSpan(
              text: ' (optionnel)',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.eleve,
    required this.count,
    required this.nomEleve,
  });
  final AppUser eleve;
  final int count;
  final String Function(AppUser) nomEleve;

  @override
  Widget build(BuildContext context) {
    final nom = nomEleve(eleve);
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.accent,  // lime
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              nom.isNotEmpty ? nom[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.accentForeground, // #111111
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nom,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),  // miroir Angular .groupe-count
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenevoleTacheItem extends StatelessWidget {
  const _BenevoleTacheItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Miroir Angular .task-card { background:#fff; border-radius:14px; padding:14px 16px; shadow }
    return Opacity(
      opacity: task.terminee ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.terminee ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: task.terminee ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
              ),
              child: task.terminee
                  ? const Icon(Icons.check,
                      size: 14, color: AppColors.accentForeground)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.titre,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: task.terminee
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.terminee
                            ? AppColors.mutedForeground
                            : AppColors.foreground,
                      ),
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (task.dateEcheance != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),  // miroir Angular .task-badge
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
          const SizedBox(width: 8),
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.mutedForeground),
            onPressed: onDelete,
            tooltip: 'Supprimer',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),        // Row
    ),          // Container
    );          // Opacity
  }
}
