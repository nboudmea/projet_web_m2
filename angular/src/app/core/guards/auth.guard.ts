import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  // TODO: remplacer par un Observable sur l'état Firebase Auth
  return auth.isLoggedIn ? true : router.createUrlTree(['/login']);
};
