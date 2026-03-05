import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DatePipe } from '@angular/common';
import { TimestampToDatePipe } from '../../../../shared/pipes/timestamp-to-date.pipe';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { Task } from '../../../../core/models/task.model';

function toDate(val: unknown): Date | undefined {
  if (!val) return undefined;
  if (val instanceof Date) return val;
  if (typeof (val as any).toDate === 'function') return (val as any).toDate();
  return new Date(val as string);
}

@Component({
  selector: 'app-eleve-taches',
  standalone: true,
  imports: [DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './eleve-taches.component.html',
  styleUrl: './eleve-taches.component.scss',
})
export class EleveTachesComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);

  private eleveId = this.authService.currentUserId!;

  readonly tasks = toSignal(
    this.taskService.getTasksEleve$(this.eleveId),
    { initialValue: [] as Task[] }
  );

  get enCours() { return this.tasks().filter(t => !t.terminee); }
  get terminees() { return this.tasks().filter(t => t.terminee); }

  private get finSemaine(): Date {
    const now = new Date();
    const day = now.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    const monday = new Date(now);
    monday.setDate(now.getDate() + diff);
    monday.setHours(0, 0, 0, 0);
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    sunday.setHours(23, 59, 59, 999);
    return sunday;
  }

  private estCetteSemaine(task: Task): boolean {
    const d = toDate((task as any).dateEcheance);
    if (!d) return true;
    return d <= this.finSemaine;
  }

  get cetteSemaine() { return this.enCours.filter(t => this.estCetteSemaine(t)); }
  get plusTard()     { return this.enCours.filter(t => !this.estCetteSemaine(t)); }

  toggle(task: Task) {
    this.taskService.toggleTask(task.id, !task.terminee);
  }
}
