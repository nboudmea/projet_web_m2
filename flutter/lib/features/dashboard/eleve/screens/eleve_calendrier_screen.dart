import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/calendar_event.dart';
import '../../../../core/models/task.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/calendar_providers.dart';
import '../../../../core/providers/task_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_card.dart';

/// Écran calendrier de l'élève — miroir de EleveCalendrierComponent Angular.
/// Grille mensuelle avec tâches à échéance et événements par jour.
class EleveCalendrierScreen extends ConsumerStatefulWidget {
  const EleveCalendrierScreen({super.key});

  @override
  ConsumerState<EleveCalendrierScreen> createState() =>
      _EleveCalendrierScreenState();
}

class _EleveCalendrierScreenState
    extends ConsumerState<EleveCalendrierScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  final _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  void _prevMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      });

  void _goToToday() => setState(() {
        _currentMonth = DateTime(_today.year, _today.month, 1);
        _selectedDate = DateTime(_today.year, _today.month, _today.day);
      });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _buildGridDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    // Lundi = 0 → offset du premier jour
    final startOffset = (firstDay.weekday - 1) % 7;
    final gridStart =
        firstDay.subtract(Duration(days: startOffset));
    return List.generate(
        42, (i) => gridStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser =
        ref.watch(authStateProvider).asData?.value;
    if (firebaseUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final tasksAsync =
        ref.watch(eleveTasksProvider(firebaseUser.uid));
    final eventsAsync = ref.watch(eventsProvider);
    final gridDays = _buildGridDays();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ──────────────────────────────────────────────────
          _CalendarHeader(
            monthLabel: DateFormat('MMMM yyyy', 'fr_FR')
                .format(_currentMonth)
                .replaceFirst(
                    _currentMonth.toString()[0],
                    _currentMonth
                        .toString()[0]
                        .toUpperCase()),
            onPrev: _prevMonth,
            onNext: _nextMonth,
            onToday: _goToToday,
          ),
          const SizedBox(height: 16),

          // ── Grille ────────────────────────────────────────────────────
          AppCard(
            child: tasksAsync.when(
              loading: () => const SizedBox(
                  height: 200,
                  child:
                      Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  Center(child: Text('Erreur : $e')),
              data: (tasks) => eventsAsync.when(
                loading: () => const SizedBox(
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator())),
                error: (e, _) =>
                    Center(child: Text('Erreur : $e')),
                data: (events) => _CalendarGrid(
                  gridDays: gridDays,
                  currentMonth: _currentMonth,
                  today: _today,
                  selectedDate: _selectedDate,
                  tasks: tasks,
                  events: events,
                  isSameDay: _isSameDay,
                  onDayTap: (day) => setState(() {
                    _selectedDate =
                        _selectedDate != null &&
                                _isSameDay(_selectedDate!, day)
                            ? null
                            : day;
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Panneau jour sélectionné ───────────────────────────────────
          if (_selectedDate != null)
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tasks) => eventsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (events) => _DayPanel(
                  date: _selectedDate!,
                  tasks: tasks
                      .where((t) =>
                          t.dateEcheance != null &&
                          _isSameDay(t.dateEcheance!, _selectedDate!))
                      .toList(),
                  events: events
                      .where((e) =>
                          _isSameDay(e.debut, _selectedDate!))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Grille calendrier ────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.gridDays,
    required this.currentMonth,
    required this.today,
    required this.selectedDate,
    required this.tasks,
    required this.events,
    required this.isSameDay,
    required this.onDayTap,
  });

  final List<DateTime> gridDays;
  final DateTime currentMonth;
  final DateTime today;
  final DateTime? selectedDate;
  final List<Task> tasks;
  final List<CalendarEvent> events;
  final bool Function(DateTime, DateTime) isSameDay;
  final void Function(DateTime) onDayTap;

  static const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête jours de la semaine
        Row(
          children: _weekDays
              .map((d) => Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const Divider(height: 1),
        // Cellules
        ...List.generate(6, (week) {
          final weekDays = gridDays.sublist(week * 7, week * 7 + 7);
          return Row(
            children: weekDays.map((day) {
              final isCurrentMonth = day.month == currentMonth.month;
              final isToday = isSameDay(day, today);
              final isSelected =
                  selectedDate != null && isSameDay(day, selectedDate!);
              final taskCount = tasks
                  .where((t) =>
                      t.dateEcheance != null &&
                      isSameDay(t.dateEcheance!, day))
                  .length;
              final eventCount = events
                  .where((e) => isSameDay(e.debut, day))
                  .length;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTap(day),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.foreground
                          : Colors.transparent,
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isToday && !isSelected
                                ? AppColors.accent
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : isCurrentMonth
                                        ? isToday
                                            ? AppColors.foreground
                                            : AppColors.foreground
                                        : AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                        if (taskCount > 0 || eventCount > 0)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              if (taskCount > 0)
                                _Dot(
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.foreground),
                              if (eventCount > 0)
                                _Dot(
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.mutedForeground),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── En-tête calendrier ───────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            monthLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        TextButton(
          onPressed: onToday,
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            foregroundColor: AppColors.foreground,
            backgroundColor: AppColors.tagBg,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Aujourd'hui",
              style:
                  TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
        const SizedBox(width: 4),
        _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.foreground),
      ),
    );
  }
}

// ─── Panneau détail du jour ────────────────────────────────────────────────────

class _DayPanel extends StatelessWidget {
  const _DayPanel({
    required this.date,
    required this.tasks,
    required this.events,
  });

  final DateTime date;
  final List<Task> tasks;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEEE d MMMM', 'fr_FR').format(date);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground),
          ),
          const SizedBox(height: 12),
          if (tasks.isEmpty && events.isEmpty)
            const Text('Aucune activité ce jour.',
                style: TextStyle(
                    color: AppColors.mutedForeground, fontSize: 14)),
          if (tasks.isNotEmpty) ...[
            const Text('Tâches',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            ...tasks.map((t) => _DayItem(
                  icon: Icons.check_box_outlined,
                  color: AppColors.foreground,
                  label: t.titre,
                  sub: t.terminee ? 'Terminée' : 'En cours',
                )),
            const SizedBox(height: 8),
          ],
          if (events.isNotEmpty) ...[
            const Text('Événements',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            ...events.map((e) => _DayItem(
                  icon: Icons.event_rounded,
                  color: AppColors.accent,
                  label: e.titre,
                  sub: DateFormat('HH:mm').format(e.debut),
                )),
          ],
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  const _DayItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Text(sub,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
