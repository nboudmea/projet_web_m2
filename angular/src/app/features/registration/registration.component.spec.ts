import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { RegistrationComponent } from './registration.component';
import { AuthService } from '../../core/services/auth.service';

const mockAuthService = {
  register: vi.fn().mockResolvedValue(undefined),
  currentAppUser$: of(null),
  currentUserId: null,
};

describe('RegistrationComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [RegistrationComponent],
      providers: [
        provideZonelessChangeDetection(),
        provideRouter([]),
        { provide: AuthService, useValue: mockAuthService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(RegistrationComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('le formulaire est invalide quand il est vide', () => {
    const fixture = TestBed.createComponent(RegistrationComponent);
    expect(fixture.componentInstance.form.invalid).toBe(true);
  });

  it('retourne une erreur si les mots de passe ne correspondent pas', () => {
    const fixture = TestBed.createComponent(RegistrationComponent);
    fixture.componentInstance.form.setValue({
      prenom: 'Alice', nom: 'Dupont', email: 'alice@test.com',
      password: 'secret1', confirmPassword: 'autremdp', role: 'eleve',
    });
    expect(fixture.componentInstance.form.errors?.['passwordsMismatch']).toBe(true);
  });

  it('le formulaire est valide quand tous les champs sont corrects', () => {
    const fixture = TestBed.createComponent(RegistrationComponent);
    fixture.componentInstance.form.setValue({
      prenom: 'Alice', nom: 'Dupont', email: 'alice@test.com',
      password: 'secret1', confirmPassword: 'secret1', role: 'eleve',
    });
    expect(fixture.componentInstance.form.valid).toBe(true);
  });
});
