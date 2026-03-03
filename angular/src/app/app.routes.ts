import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { publicGuard } from './core/guards/public.guard';

export const routes: Routes = [
  {
    path: 'login',
    canActivate: [publicGuard],
    loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent),
  },
  {
    path: '',
    canActivate: [authGuard],
    children: [
      // TODO: ajouter dashboard, chat, calendar, tasks
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: 'login' },
];

