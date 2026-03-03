import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { publicGuard } from './core/guards/public.guard';

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
  // Dashboard — redirect
  {
    path: 'dashboard',
    canActivate: [authGuard],
    children: [
      {
        path: 'eleve',
        loadComponent: () => import('./features/dashboard/eleve/eleve-dashboard.component').then(m => m.EleveDashboardComponent),
        children: [
          { path: 'accueil', loadComponent: () => import('./features/dashboard/eleve/accueil/eleve-accueil.component').then(m => m.EleveAccueilComponent) },
          { path: 'taches',  loadComponent: () => import('./features/dashboard/eleve/taches/eleve-taches.component').then(m => m.EleveTachesComponent) },
          { path: '', redirectTo: 'accueil', pathMatch: 'full' },
        ],
      },
      { path: '', redirectTo: 'eleve', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: '' },
];

