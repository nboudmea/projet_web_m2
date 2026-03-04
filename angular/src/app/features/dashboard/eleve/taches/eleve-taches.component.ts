import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DatePipe } from '@angular/common';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { Task } from '../../../../core/models/task.model';

@Component({
  selector: 'app-eleve-taches',
  standalone: true,
  imports: [DatePipe],
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

  get enCours() {
    return this.tasks().filter(t => !t.terminee);
  }

  get terminees() {
    return this.tasks().filter(t => t.terminee);
  }

  toggle(task: Task) {
    this.taskService.toggleTask(task.id, !task.terminee);
  }
}
