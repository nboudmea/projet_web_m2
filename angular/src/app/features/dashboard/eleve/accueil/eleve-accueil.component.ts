import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { DatePipe } from '@angular/common';
import { TimestampToDatePipe } from '../../../../shared/pipes/timestamp-to-date.pipe';
import { switchMap, of } from 'rxjs';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { UserService } from '../../../../core/services/user.service';
import { Task } from '../../../../core/models/task.model';
import { User } from '../../../../core/models/user.model';

@Component({
  selector: 'app-eleve-accueil',
  standalone: true,
  imports: [RouterLink, DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './eleve-accueil.component.html',
  styleUrl: './eleve-accueil.component.scss',
})
export class EleveAccueilComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);
  private userService = inject(UserService);

  private eleveId = this.authService.currentUserId!;

  readonly tasks = toSignal(
    this.taskService.getTasksEleve$(this.eleveId),
    { initialValue: [] as Task[] }
  );

  /** Bénévole assigné — null si aucun ou en chargement */
  readonly benevole = toSignal(
    this.authService.currentAppUser$.pipe(
      switchMap(user => user?.benevoleId
        ? this.userService.getUserById$(user.benevoleId)
        : of(null)
      )
    ),
    { initialValue: null as User | null }
  );

  get tachesEnCours() {
    return this.tasks().filter(t => !t.terminee);
  }

  get tachesTerminees() {
    return this.tasks().filter(t => t.terminee);
  }

  get progression(): number {
    const total = this.tasks().length;
    if (!total) return 0;
    return Math.round((this.tachesTerminees.length / total) * 100);
  }

  nomBenevole(b: User): string {
    const full = `${b.prenom ?? ''} ${b.nom ?? ''}`.trim();
    return full || b.email;
  }
}
