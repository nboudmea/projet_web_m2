import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { map, take } from 'rxjs';

/**
 * Redirige vers /dashboard/eleve ou /dashboard/benevole
 * selon le rôle Firestore de l'utilisateur connecté.
 */
export const roleRedirectGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.currentAppUser$.pipe(
    take(1),
    map(user => {
      if (!user) return router.createUrlTree(['/login']);
      return user.role === 'benevole'
        ? router.createUrlTree(['/dashboard/benevole'])
        : router.createUrlTree(['/dashboard/eleve']);
    })
  );
};
