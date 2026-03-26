import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { LoginComponent } from './login.component';
import { AuthService } from '../../core/services/auth.service';

const mockAuthService = {
  login: vi.fn().mockResolvedValue(undefined),
  resetPassword: vi.fn().mockResolvedValue(undefined),
  currentAppUser$: of(null),
  currentUserId: null,
};

describe('LoginComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [LoginComponent],
      providers: [
        provideZonelessChangeDetection(),
        provideRouter([]),
        { provide: AuthService, useValue: mockAuthService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(LoginComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('le formulaire est invalide quand il est vide', () => {
    const fixture = TestBed.createComponent(LoginComponent);
    expect(fixture.componentInstance.form.invalid).toBe(true);
  });

  it('le champ email est invalide avec une valeur non-email', () => {
    const fixture = TestBed.createComponent(LoginComponent);
    fixture.componentInstance.form.setValue({ email: 'pas-un-email', password: 'motdepasse' });
    expect(fixture.componentInstance.email?.invalid).toBe(true);
  });

  it('le formulaire est valide avec des données correctes', () => {
    const fixture = TestBed.createComponent(LoginComponent);
    fixture.componentInstance.form.setValue({ email: 'test@example.com', password: 'motdepasse' });
    expect(fixture.componentInstance.form.valid).toBe(true);
  });

  it('onSubmit ne déclenche pas login si le formulaire est invalide', async () => {
    const fixture = TestBed.createComponent(LoginComponent);
    await fixture.componentInstance.onSubmit();
    expect(mockAuthService.login).not.toHaveBeenCalled();
  });
});
