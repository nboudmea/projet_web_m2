import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { UserService } from '../../../../core/services/user.service';
import { Task } from '../../../../core/models/task.model';
import { User } from '../../../../core/models/user.model';

@Component({
  selector: 'app-benevole-taches',
  standalone: true,
  imports: [ReactiveFormsModule, DatePipe],
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

  /** Élève sélectionné pour filtrer les tâches — null = tous */
  readonly selectedEleveId = signal<string | null>(null);

  readonly form = this.fb.group({
    assigneeId:   ['', Validators.required],
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

  /** Tâches filtrées selon l'élève sélectionné (null = toutes) */
  get tasksFiltrees(): Task[] {
    const sel = this.selectedEleveId();
    return sel ? this.tasks().filter(t => t.assigneeId === sel) : this.tasks();
  }

  /** Tâches groupées par élève sur le résultat filtré */
  get groupes(): { eleve: User; tasks: Task[] }[] {
    const map = new Map<string, Task[]>();
    for (const t of this.tasksFiltrees) {
      if (!map.has(t.assigneeId)) map.set(t.assigneeId, []);
      map.get(t.assigneeId)!.push(t);
    }
    return Array.from(map.entries())
      .map(([id, tasks]) => ({
        eleve: this.elevesMap.get(id) ?? { id, email: id } as User,
        tasks,
      }));
  }

  nomEleve(eleve: User): string {
    const full = `${eleve.prenom ?? ''} ${eleve.nom ?? ''}`.trim();
    return full || eleve.email || 'Élève inconnu';
  }

  /** Sélectionne/désélectionne un élève et pré-remplit le select du formulaire */
  selectEleve(id: string | null): void {
    this.selectedEleveId.set(id);
    this.form.patchValue({ assigneeId: id ?? '' });
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
  }

  toggle(task: Task) {
    this.taskService.toggleTask(task.id, !task.terminee);
  }

  delete(taskId: string) {
    this.taskService.deleteTask(taskId);
  }
}
