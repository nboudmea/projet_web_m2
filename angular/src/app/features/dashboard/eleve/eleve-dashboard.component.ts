import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';

@Component({
  selector: 'app-eleve-dashboard',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './eleve-dashboard.component.html',
  styleUrl: './eleve-dashboard.component.scss',
})
export class EleveDashboardComponent {
  private authService = inject(AuthService);
  private router = inject(Router);

  readonly navItems = [
    { label: 'Accueil',     path: 'accueil',     icon: 'home' },
    { label: 'Tâches',     path: 'taches',      icon: 'tasks' },
    { label: 'Calendrier', path: 'calendrier',  icon: 'calendar' },
  ];

  logout() {
    this.authService.logout().then(() => this.router.navigateByUrl('/'));
  }
}
