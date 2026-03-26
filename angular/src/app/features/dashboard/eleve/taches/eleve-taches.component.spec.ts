import { TestBed } from '@angular/core/testing';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { EleveTachesComponent } from './eleve-taches.component';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { Task } from '../../../../core/models/task.model';

const tacheEnCours: Task = {
  id: '1', titre: 'Tâche active', terminee: false,
  assigneeId: 'eleve-1', createurId: 'eleve-1',
};
const tacheTerminee: Task = {
  id: '2', titre: 'Tâche terminée', terminee: true,
  assigneeId: 'eleve-1', createurId: 'eleve-1',
};

const mockAuthService = {
  currentAppUser$: of(null),
  currentUserId: 'eleve-1',
};

const mockTaskService = {
  getTasksEleve$: vi.fn().mockReturnValue(of([tacheEnCours, tacheTerminee])),
  toggleTask: vi.fn().mockResolvedValue(undefined),
};

describe('EleveTachesComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [EleveTachesComponent],
      providers: [
        provideZonelessChangeDetection(),
        { provide: AuthService, useValue: mockAuthService },
        { provide: TaskService, useValue: mockTaskService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(EleveTachesComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('enCours ne contient que les tâches non terminées', () => {
    const fixture = TestBed.createComponent(EleveTachesComponent);
    expect(fixture.componentInstance.enCours.every(t => !t.terminee)).toBe(true);
  });

  it('terminees ne contient que les tâches terminées', () => {
    const fixture = TestBed.createComponent(EleveTachesComponent);
    expect(fixture.componentInstance.terminees.every(t => t.terminee)).toBe(true);
  });
});
