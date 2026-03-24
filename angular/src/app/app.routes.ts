import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { publicGuard } from './core/guards/public.guard';
import { roleRedirectGuard } from './core/guards/role-redirect.guard';

export const routes: Routes = [
  // Page publique d'accueil
  {
    path: '',
    loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent),
  },
  // Pages auth (redirige vers dashboard si déjà connecté)
  {
    path: 'login',
    canActivate: [publicGuard],
    loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent),
  },
  {
    path: 'register',
    canActivate: [publicGuard],
    loadComponent: () => import('./features/registration/registration.component').then(m => m.RegistrationComponent),
  },
  // Dashboard — redirection selon rôle + sous-dashboards
  {
    path: 'dashboard',
    canActivate: [authGuard],
    children: [
      // Dashboard élève
      {
        path: 'eleve',
        loadComponent: () => import('./features/dashboard/eleve/eleve-dashboard.component').then(m => m.EleveDashboardComponent),
        children: [
          { path: 'accueil',     loadComponent: () => import('./features/dashboard/eleve/accueil/eleve-accueil.component').then(m => m.EleveAccueilComponent) },
          { path: 'taches',      loadComponent: () => import('./features/dashboard/eleve/taches/eleve-taches.component').then(m => m.EleveTachesComponent) },
          { path: 'calendrier',  loadComponent: () => import('./features/dashboard/eleve/calendrier/eleve-calendrier.component').then(m => m.EleveCalendrierComponent) },
          { path: 'chat',        loadComponent: () => import('./features/chat/chat.component').then(m => m.ChatComponent) },
          { path: '', redirectTo: 'accueil', pathMatch: 'full' },
        ],
      },
      // Dashboard bénévole
      {
        path: 'benevole',
        loadComponent: () => import('./features/dashboard/benevole/benevole-dashboard.component').then(m => m.BenevoleDashboardComponent),
        children: [
          { path: 'accueil',     loadComponent: () => import('./features/dashboard/benevole/accueil/benevole-accueil.component').then(m => m.BenevoleAccueilComponent) },
          { path: 'taches',      loadComponent: () => import('./features/dashboard/benevole/taches/benevole-taches.component').then(m => m.BenevoleTachesComponent) },
          { path: 'calendrier',  loadComponent: () => import('./features/dashboard/benevole/calendrier/benevole-calendrier.component').then(m => m.BenevoleCalendrierComponent) },
          { path: 'chat',        loadComponent: () => import('./features/chat/chat.component').then(m => m.ChatComponent) },
          { path: '', redirectTo: 'accueil', pathMatch: 'full' },
        ],
      },
      // Redirection par rôle depuis /dashboard
      {
        path: '',
        canActivate: [roleRedirectGuard],
        loadComponent: () => import('./features/dashboard/role-redirect.component').then(m => m.RoleRedirectComponent),
        pathMatch: 'full',
      },
    ],
  },
  { path: '**', redirectTo: '' },
];

