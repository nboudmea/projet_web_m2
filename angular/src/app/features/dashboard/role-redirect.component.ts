import { ChangeDetectionStrategy, Component } from '@angular/core';

/** Composant vide — jamais affiché. La roleRedirectGuard redirige avant le rendu. */
@Component({
  selector: 'app-role-redirect',
  standalone: true,
  template: '',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RoleRedirectComponent {}
