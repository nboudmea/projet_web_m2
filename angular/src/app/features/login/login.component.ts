import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);

  // État du composant
  isLoading = signal(false); // Indique si une requête de connexion est en cours
  errorMessage = signal<string | null>(null); // Message d'erreur à afficher en cas d'échec de connexion

  // Définition du formulaire avec ses validations
  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
  });

  // Raccourcis pour accéder aux champs depuis le template
  get email() { return this.form.get('email'); }
  get password() { return this.form.get('password'); }

  async onSubmit(): Promise<void> {
    if (this.form.invalid) return;

    this.isLoading.set(true);
    this.errorMessage.set(null);

    try {
      await this.authService.login(
        this.email!.value!,
        this.password!.value!,
      );
      this.router.navigate(['/dashboard']);
    } catch (error: any) {
      this.errorMessage.set(this.getErrorMessage(error.code));
    } finally {
      this.isLoading.set(false);
    }
  }

  async onForgotPassword(): Promise<void> {
    const email = this.email!.value;
    if (!email) {
      this.errorMessage.set('Saisis ton email avant de demander une réinitialisation.');
      return;
    }
    try {
      await this.authService.resetPassword(email);
      this.errorMessage.set(null);
      alert('Email de réinitialisation envoyé !');
    } catch {
      this.errorMessage.set('Impossible d\'envoyer l\'email. Vérifie l\'adresse saisie.');
    }
  }

  // Traduit les codes d'erreur Firebase en messages lisibles
  private getErrorMessage(code: string): string {
    switch (code) {
      case 'auth/user-not-found':
      case 'auth/wrong-password':
      case 'auth/invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'auth/too-many-requests':
        return 'Trop de tentatives. Réessaie dans quelques minutes.';
      case 'auth/user-disabled':
        return 'Ce compte a été désactivé.';
      default:
        return 'Une erreur est survenue. Réessaie.';
    }
  }
}

