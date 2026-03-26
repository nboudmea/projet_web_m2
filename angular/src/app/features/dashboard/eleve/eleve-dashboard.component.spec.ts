import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { EleveDashboardComponent } from './eleve-dashboard.component';
import { AuthService } from '../../../core/services/auth.service';

const mockAuthService = {
  currentAppUser$: of(null),
  logout: vi.fn().mockResolvedValue(undefined),
};

describe('EleveDashboardComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [EleveDashboardComponent],
      providers: [
        provideZonelessChangeDetection(),
        provideRouter([]),
        { provide: AuthService, useValue: mockAuthService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(EleveDashboardComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('expose 4 éléments de navigation', () => {
    const fixture = TestBed.createComponent(EleveDashboardComponent);
    expect(fixture.componentInstance.navItems.length).toBe(4);
  });

  it('logout appelle authService.logout', () => {
    const fixture = TestBed.createComponent(EleveDashboardComponent);
    fixture.componentInstance.logout();
    expect(mockAuthService.logout).toHaveBeenCalled();
  });
});
