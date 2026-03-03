import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// Empêche un utilisateur déjà connecté d'accéder à la page login
export const publicGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isLoggedIn ? router.createUrlTree(['/dashboard']) : true;
};
