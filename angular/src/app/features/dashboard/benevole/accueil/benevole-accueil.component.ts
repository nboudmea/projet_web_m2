import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { UserService } from '../../../../core/services/user.service';
import { Task } from '../../../../core/models/task.model';
import { User } from '../../../../core/models/user.model';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'app-benevole-accueil',
  standalone: true,
  imports: [RouterLink, AsyncPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './benevole-accueil.component.html',
  styleUrl: './benevole-accueil.component.scss',
})
export class BenevoleAccueilComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);
  private userService = inject(UserService);

  private benevoleId = this.authService.currentUserId!;

  readonly currentUser$ = this.authService.currentAppUser$;

  readonly eleves = toSignal(
    this.userService.getElevesOfBenevole$(this.benevoleId),
    { initialValue: [] as User[] }
  );

  readonly tasks = toSignal(
    this.taskService.getTasksBenevole$(this.benevoleId),
    { initialValue: [] as Task[] }
  );

  get tachesEnCours() {
    return this.tasks().filter(t => !t.terminee);
  }

  get tachesTerminees() {
    return this.tasks().filter(t => t.terminee);
  }

  /** Nb de tâches (non terminées) par élève */
  tachesCount(eleveId: string): number {
    return this.tasks().filter(t => t.assigneeId === eleveId && !t.terminee).length;
  }

  nomEleve(eleve: User): string {
    const full = `${this.cap(eleve.prenom)} ${this.cap(eleve.nom)}`.trim();
    return full || eleve.email || 'Élève sans nom';
  }

  cap(s: string | undefined): string {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }
}
