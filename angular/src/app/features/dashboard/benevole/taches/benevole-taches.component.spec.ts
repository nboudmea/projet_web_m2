import { TestBed } from '@angular/core/testing';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { BenevoleTachesComponent } from './benevole-taches.component';
import { AuthService } from '../../../../core/services/auth.service';
import { TaskService } from '../../../../core/services/task.service';
import { UserService } from '../../../../core/services/user.service';

const mockAuthService = {
  currentAppUser$: of(null),
  currentUserId: 'benevole-1',
};

const mockTaskService = {
  getTasksBenevole$: vi.fn().mockReturnValue(of([])),
  createTask: vi.fn().mockResolvedValue(undefined),
  deleteTask: vi.fn().mockResolvedValue(undefined),
  toggleTask: vi.fn().mockResolvedValue(undefined),
};

const mockUserService = {
  getElevesOfBenevole$: vi.fn().mockReturnValue(of([])),
};

describe('BenevoleTachesComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [BenevoleTachesComponent],
      providers: [
        provideZonelessChangeDetection(),
        { provide: AuthService, useValue: mockAuthService },
        { provide: TaskService, useValue: mockTaskService },
        { provide: UserService, useValue: mockUserService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(BenevoleTachesComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('le formulaire de création est invalide quand vide', () => {
    const fixture = TestBed.createComponent(BenevoleTachesComponent);
    expect(fixture.componentInstance.form.invalid).toBe(true);
  });

  it('la liste de tâches est vide par défaut', () => {
    const fixture = TestBed.createComponent(BenevoleTachesComponent);
    expect(fixture.componentInstance.tasks()).toEqual([]);
  });

  it('selectedEleveId est null par défaut (aucun filtre)', () => {
    const fixture = TestBed.createComponent(BenevoleTachesComponent);
    expect(fixture.componentInstance.selectedEleveId()).toBeNull();
  });
});
