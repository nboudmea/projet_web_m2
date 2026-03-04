import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-benevole-dashboard',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './benevole-dashboard.component.html',
  styleUrl: './benevole-dashboard.component.scss',
})
export class BenevoleDashboardComponent {
  private authService = inject(AuthService);
  private router = inject(Router);

  readonly navItems = [
    { label: 'Accueil', path: 'accueil', icon: 'home' },
    { label: 'Tâches',  path: 'taches',  icon: 'tasks' },
  ];

  logout() {
    this.authService.logout().then(() => this.router.navigateByUrl('/'));
  }
}
