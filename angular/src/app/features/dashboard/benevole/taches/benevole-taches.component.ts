import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { TimestampToDatePipe } from '../../../../shared/pipes/timestamp-to-date.pipe';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { UserService } from '../../../../core/services/user.service';
import { Task } from '../../../../core/models/task.model';
import { User } from '../../../../core/models/user.model';

/** Normalise une dateEcheance qui peut être Date, Firestore Timestamp ou string */
function toDate(val: unknown): Date | undefined {
  if (!val) return undefined;
  if (val instanceof Date) return val;
  if (typeof (val as any).toDate === 'function') return (val as any).toDate();
  return new Date(val as string);
}

@Component({
  selector: 'app-benevole-taches',
  standalone: true,
  imports: [ReactiveFormsModule, DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './benevole-taches.component.html',
  styleUrl: './benevole-taches.component.scss',
})
export class BenevoleTachesComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);
  private userService = inject(UserService);
  private fb = inject(FormBuilder);

  private benevoleId = this.authService.currentUserId!;

  readonly eleves = toSignal(
    this.userService.getElevesOfBenevole$(this.benevoleId),
    { initialValue: [] as User[] }
  );

  readonly tasks = toSignal(
    this.taskService.getTasksBenevole$(this.benevoleId),
    { initialValue: [] as Task[] }
  );

  readonly submitting = signal(false);
  readonly submitted = signal(false);

  /** Formulaire de création ouvert */
  readonly creatingTask = signal(false);

  /** Tâche en cours d'édition (null = modale fermée) */
  readonly editingTask = signal<Task | null>(null);
  readonly saving = signal(false);

  /** Élève sélectionné pour filtrer les tâches — null = tous */
  readonly selectedEleveId = signal<string | null>(null);

  readonly form = this.fb.group({
    assigneeId:   ['', Validators.required],
    titre:        ['', Validators.required],
    description:  [''],
    dateEcheance: [''],
  });

  readonly editForm = this.fb.group({
    titre:        ['', Validators.required],
    description:  [''],
    dateEcheance: [''],
  });

  /** Map userId → User pour afficher le nom dans la liste */
  get elevesMap(): Map<string, User> {
    const map = new Map<string, User>();
    for (const e of this.eleves()) map.set(e.id, e);
    return map;
  }

  // ── Helpers semaine ────────────────────────────────────────────────────────

  private get debutSemaine(): Date {
    const now = new Date();
    const day = now.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    const d = new Date(now);
    d.setDate(now.getDate() + diff);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  private get finSemaine(): Date {
    const d = new Date(this.debutSemaine);
    d.setDate(d.getDate() + 6);
    d.setHours(23, 59, 59, 999);
    return d;
  }

  private estCetteSemaine(task: Task): boolean {
    const d = toDate((task as any).dateEcheance);
    if (!d) return true; // sans date → affiché dans "cette semaine"
    return d <= this.finSemaine;
  }

  // ── Filtres & groupes ───────────────────────────────────────────────────────

  /** Tâches filtrées selon l'élève sélectionné (null = toutes), non terminées */
  get tasksFiltrees(): Task[] {
    const sel = this.selectedEleveId();
    return (sel ? this.tasks().filter(t => t.assigneeId === sel) : this.tasks())
      .filter(t => !t.terminee);
  }

  get tachesCetteSemaine(): Task[] {
    return this.tasksFiltrees.filter(t => this.estCetteSemaine(t));
  }

  get tachesPlusTard(): Task[] {
    return this.tasksFiltrees.filter(t => !this.estCetteSemaine(t));
  }

  /** Tâches terminées (tous élèves ou filtrées) */
  get tachesTerminees(): Task[] {
    const sel = this.selectedEleveId();
    return (sel ? this.tasks().filter(t => t.assigneeId === sel) : this.tasks())
      .filter(t => t.terminee);
  }

  private grouper(liste: Task[]): { eleve: User; tasks: Task[] }[] {
    const map = new Map<string, Task[]>();
    for (const t of liste) {
      if (!map.has(t.assigneeId)) map.set(t.assigneeId, []);
      map.get(t.assigneeId)!.push(t);
    }
    return Array.from(map.entries()).map(([id, tasks]) => ({
      eleve: this.elevesMap.get(id) ?? { id, email: id } as User,
      tasks,
    }));
  }

  /** Tâches groupées par élève sur le résultat filtré */
  get groupes(): { eleve: User; tasks: Task[] }[] {
    return this.grouper(this.tasksFiltrees);
  }

  get groupesCetteSemaine(): { eleve: User; tasks: Task[] }[] {
    return this.grouper(this.tachesCetteSemaine);
  }

  get groupesPlusTard(): { eleve: User; tasks: Task[] }[] {
    return this.grouper(this.tachesPlusTard);
  }

  nomEleve(eleve: User): string {
    const full = `${this.cap(eleve.prenom)} ${this.cap(eleve.nom)}`.trim();
    return full || eleve.email || 'Élève inconnu';
  }

  private cap(s: string | undefined): string {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  /** Sélectionne/désélectionne un élève et pré-remplit le select du formulaire */
  selectEleve(id: string | null): void {
    this.selectedEleveId.set(id);
    this.form.patchValue({ assigneeId: id ?? '' });
  }

  openCreate(): void {
    this.submitted.set(false);
    this.form.reset({ assigneeId: this.selectedEleveId() ?? '', titre: '', description: '', dateEcheance: '' });
    this.creatingTask.set(true);
  }

  cancelCreate(): void {
    this.creatingTask.set(false);
  }

  async submit() {
    this.submitted.set(true);
    if (this.form.invalid) return;

    this.submitting.set(true);
    const { assigneeId, titre, description, dateEcheance } = this.form.getRawValue();
    await this.taskService.createTask({
      assigneeId: assigneeId!,
      createurId: this.benevoleId,
      titre: titre!,
      description: description || undefined,
      dateEcheance: dateEcheance ? new Date(dateEcheance) : undefined,
      terminee: false,
    });
    this.form.patchValue({ titre: '', description: '', dateEcheance: '' });
    this.submitted.set(false);
    this.submitting.set(false);
    this.creatingTask.set(false);
  }

  toggle(task: Task) {
    this.taskService.toggleTask(task.id, !task.terminee);
  }

  delete(taskId: string) {
    this.taskService.deleteTask(taskId);
  }

  // ── Édition ─────────────────────────────────────────────────────────────────

  openEdit(task: Task): void {
    const d = toDate((task as any).dateEcheance);
    this.editForm.setValue({
      titre:        task.titre,
      description:  task.description ?? '',
      dateEcheance: d ? d.toISOString().split('T')[0] : '',
    });
    this.editingTask.set(task);
  }

  cancelEdit(): void {
    this.editingTask.set(null);
  }

  async saveEdit(): Promise<void> {
    if (this.editForm.invalid) return;
    this.saving.set(true);
    const task = this.editingTask()!;
    const { titre, description, dateEcheance } = this.editForm.getRawValue();
    await this.taskService.updateTask(task.id, {
      titre: titre!,
      description: description || undefined,
      dateEcheance: dateEcheance ? new Date(dateEcheance) : undefined,
    });
    this.saving.set(false);
    this.editingTask.set(null);
  }
}
