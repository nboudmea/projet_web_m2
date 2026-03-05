import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DatePipe } from '@angular/common';
import { TimestampToDatePipe } from '../../../../shared/pipes/timestamp-to-date.pipe';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { CalendarService } from '../../../../core/services/calendar.service';
import { Task } from '../../../../core/models/task.model';
import { CalendarEvent } from '../../../../core/models/calendar-event.model';

/** Normalise une date Firestore Timestamp ou string en Date JS */
function toDate(val: unknown): Date | undefined {
  if (!val) return undefined;
  if (val instanceof Date) return val;
  if (typeof (val as any).toDate === 'function') return (val as any).toDate();
  const d = new Date(val as string);
  return isNaN(d.getTime()) ? undefined : d;
}

function isSameDay(a: Date, b: Date): boolean {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

export interface DayCell {
  date: Date;
  isCurrentMonth: boolean;
  isToday: boolean;
  taskCount: number;
  eventCount: number;
}

@Component({
  selector: 'app-eleve-calendrier',
  standalone: true,
  imports: [DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './eleve-calendrier.component.html',
  styleUrl: './eleve-calendrier.component.scss',
})
export class EleveCalendrierComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);
  private calendarService = inject(CalendarService);

  private eleveId = this.authService.currentUserId!;
  private today = new Date();

  /** Mois affiché — premier jour du mois courant */
  readonly currentMonth = signal(
    new Date(this.today.getFullYear(), this.today.getMonth(), 1)
  );

  /** Jour sélectionné */
  readonly selectedDate = signal<Date | null>(null);

  readonly tasks = toSignal(
    this.taskService.getTasksEleve$(this.eleveId),
    { initialValue: [] as Task[] }
  );

  readonly events = toSignal(
    this.calendarService.getEvents$(this.eleveId),
    { initialValue: [] as CalendarEvent[] }
  );

  // ── Calendrier ────────────────────────────────────────────────────────────

  readonly monthLabel = computed(() => {
    return this.currentMonth().toLocaleDateString('fr-FR', {
      month: 'long',
      year: 'numeric',
    });
  });

  readonly days = computed<DayCell[]>(() => {
    const month = this.currentMonth();
    const year = month.getFullYear();
    const mo = month.getMonth();

    // Premier jour de la grille (lundi de la semaine qui contient le 1er)
    const firstDay = new Date(year, mo, 1);
    const startOffset = (firstDay.getDay() + 6) % 7; // lundi = 0
    const gridStart = new Date(year, mo, 1 - startOffset);

    // 42 cellules (6 semaines)
    const cells: DayCell[] = [];
    for (let i = 0; i < 42; i++) {
      const date = new Date(gridStart);
      date.setDate(gridStart.getDate() + i);

      const taskCount = this.tasks().filter(t => {
        const d = toDate((t as any).dateEcheance);
        return d ? isSameDay(d, date) : false;
      }).length;

      const eventCount = this.events().filter(e => {
        const d = toDate((e as any).debut);
        return d ? isSameDay(d, date) : false;
      }).length;

      cells.push({
        date,
        isCurrentMonth: date.getMonth() === mo,
        isToday: isSameDay(date, this.today),
        taskCount,
        eventCount,
      });
    }
    return cells;
  });

  readonly weeks = computed<DayCell[][]>(() => {
    const all = this.days();
    const w: DayCell[][] = [];
    for (let i = 0; i < 42; i += 7) w.push(all.slice(i, i + 7));
    return w;
  });

  // ── Tâches / événements du jour sélectionné ────────────────────────────────
  // NOTE : getters simples (pas de computed) pour garantir une évaluation
  // fraîche à chaque rendu, contournant un problème de cache computed
  // avec provideZonelessChangeDetection + OnPush + @if.

  get tasksOfDay(): Task[] {
    const sel = this.selectedDate();
    if (!sel) return [];
    return this.tasks().filter(t => {
      const d = toDate((t as any).dateEcheance);
      return d ? isSameDay(d, sel) : false;
    });
  }

  get eventsOfDay(): CalendarEvent[] {
    const sel = this.selectedDate();
    if (!sel) return [];
    return this.events().filter(e => {
      const d = toDate((e as any).debut);
      return d ? isSameDay(d, sel) : false;
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  prevMonth(): void {
    const m = this.currentMonth();
    this.currentMonth.set(new Date(m.getFullYear(), m.getMonth() - 1, 1));
  }

  nextMonth(): void {
    const m = this.currentMonth();
    this.currentMonth.set(new Date(m.getFullYear(), m.getMonth() + 1, 1));
  }

  goToToday(): void {
    this.currentMonth.set(
      new Date(this.today.getFullYear(), this.today.getMonth(), 1)
    );
    this.selectedDate.set(this.today);
  }

  selectDay(cell: DayCell): void {
    const sel = this.selectedDate();
    if (sel && isSameDay(sel, cell.date)) {
      this.selectedDate.set(null);
    } else {
      this.selectedDate.set(cell.date);
    }
  }

  isSelected(cell: DayCell): boolean {
    const sel = this.selectedDate();
    return sel ? isSameDay(sel, cell.date) : false;
  }

  toggle(task: Task): void {
    this.taskService.toggleTask(task.id, !task.terminee);
  }
}
