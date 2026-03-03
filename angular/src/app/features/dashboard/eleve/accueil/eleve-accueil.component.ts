import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { AsyncPipe, DatePipe } from '@angular/common';
import { map } from 'rxjs';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { Task } from '../../../../core/models/task.model';

@Component({
  selector: 'app-eleve-accueil',
  standalone: true,
  imports: [RouterLink, DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './eleve-accueil.component.html',
  styleUrl: './eleve-accueil.component.scss',
})
export class EleveAccueilComponent {
  private authService = inject(AuthService);
  private taskService = inject(TaskService);

  private eleveId = this.authService.currentUserId!;

  readonly tasks = toSignal(
    this.taskService.getTasksEleve$(this.eleveId),
    { initialValue: [] as Task[] }
  );

  get tachesEnCours() {
    return this.tasks().filter(t => !t.terminee);
  }

  get tachesTerminees() {
    return this.tasks().filter(t => t.terminee);
  }

  // Pour la barre de progression
  get progression(): number {
    const total = this.tasks().length;
    if (!total) return 0;
    return Math.round((this.tachesTerminees.length / total) * 100);
  }
}
