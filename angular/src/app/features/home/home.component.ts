import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { AsyncPipe } from '@angular/common';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [RouterLink, AsyncPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss',
})
export class HomeComponent {
  private authService = inject(AuthService);
  private router = inject(Router);
  readonly currentUser$ = this.authService.currentUser$;

  logout() {
    this.authService.logout().then(() => this.router.navigateByUrl('/'));
  }
  readonly stats = [
    { value: '2 400+', label: 'élèves accompagnés' },
    { value: '1 800+', label: 'bénévoles actifs' },
    { value: '96%', label: 'de satisfaction' },
  ];

  readonly values = [
    {
      icon: '🤝',
      title: 'Entraide',
      desc: 'Des bénévoles passionnés qui donnent de leur temps pour aider des jeunes à progresser.',
    },
    {
      icon: '📍',
      title: 'Accessibilité',
      desc: 'Peu importe où tu vis, tu mérites un soutien scolaire de qualité, en ligne.',
    },
    {
      icon: '🌱',
      title: 'Confiance',
      desc: 'Un environnement bienveillant où chaque élève peut apprendre à son rythme.',
    },
  ];

  readonly steps = [
    { num: '01', title: 'Crée ton compte', desc: 'Inscris-toi en tant qu\'élève ou bénévole en quelques secondes.' },
    { num: '02', title: 'Rencontre ton tuteur', desc: 'Un bénévole dédié est assigné à chaque élève selon ses besoins.' },
    { num: '03', title: 'Progresse ensemble', desc: 'Des rendez-vous hebdomadaires pour travailler les devoirs et s\'organiser.' },
  ];
}
