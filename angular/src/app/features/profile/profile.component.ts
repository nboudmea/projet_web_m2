import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  inject,
  signal,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { toSignal } from '@angular/core/rxjs-interop';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';
import { AvatarUploadComponent } from '../../shared/components/avatar-upload/avatar-upload.component';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, AvatarUploadComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss',
})
export class ProfileComponent implements OnInit {
  private authService = inject(AuthService);
  private userService = inject(UserService);
  private fb = inject(FormBuilder);

  readonly user = toSignal(this.authService.currentAppUser$);

  // ---- Formulaire infos personnelles ----
  readonly infoForm = this.fb.group({
    prenom: ['', Validators.required],
    nom:    ['', Validators.required],
  });

  readonly infoSaving  = signal(false);
  readonly infoSuccess = signal(false);
  readonly infoError   = signal<string | null>(null);

  // ---- Formulaire email ----
  readonly emailForm = this.fb.group({
    newEmail:        ['', [Validators.required, Validators.email]],
    passwordForEmail: ['', Validators.required],
  });

  readonly emailSaving  = signal(false);
  readonly emailSuccess = signal(false);
  readonly emailError   = signal<string | null>(null);

  // ---- Formulaire mot de passe ----
  readonly pwForm = this.fb.group({
    currentPassword: ['', Validators.required],
    newPassword:     ['', [Validators.required, Validators.minLength(6)]],
    confirmPassword: ['', Validators.required],
  });

  readonly pwSaving  = signal(false);
  readonly pwSuccess = signal(false);
  readonly pwError   = signal<string | null>(null);

  ngOnInit(): void {
    // Pré-remplir le formulaire dès que l'utilisateur est chargé
    const u = this.user();
    if (u) {
      this.infoForm.patchValue({ prenom: u.prenom, nom: u.nom });
    } else {
      // Observer les changements en cas de chargement tardif
      this.authService.currentAppUser$.subscribe(user => {
        if (user) this.infoForm.patchValue({ prenom: user.prenom, nom: user.nom });
      });
    }
  }

  saveInfo(): void {
    if (this.infoForm.invalid) return;
    const u = this.user();
    if (!u) return;

    this.infoSaving.set(true);
    this.infoError.set(null);
    this.infoSuccess.set(false);

    const { prenom, nom } = this.infoForm.getRawValue();
    this.userService.updateProfile(u.id, { prenom: prenom!, nom: nom! })
      .then(() => this.infoSuccess.set(true))
      .catch(() => this.infoError.set('Erreur lors de la sauvegarde.'))
      .finally(() => this.infoSaving.set(false));
  }

  saveEmail(): void {
    if (this.emailForm.invalid) return;

    this.emailSaving.set(true);
    this.emailError.set(null);
    this.emailSuccess.set(false);

    const { newEmail, passwordForEmail } = this.emailForm.getRawValue();
    this.authService.changeEmail(newEmail!, passwordForEmail!)
      .then(() => {
        this.emailSuccess.set(true);
        this.emailForm.reset();
      })
      .catch(err => this.emailError.set(this.mapFirebaseError(err)))
      .finally(() => this.emailSaving.set(false));
  }

  savePassword(): void {
    if (this.pwForm.invalid) return;

    const { currentPassword, newPassword, confirmPassword } = this.pwForm.getRawValue();
    if (newPassword !== confirmPassword) {
      this.pwError.set('Les mots de passe ne correspondent pas.');
      return;
    }

    this.pwSaving.set(true);
    this.pwError.set(null);
    this.pwSuccess.set(false);

    this.authService.changePassword(currentPassword!, newPassword!)
      .then(() => {
        this.pwSuccess.set(true);
        this.pwForm.reset();
      })
      .catch(err => this.pwError.set(this.mapFirebaseError(err)))
      .finally(() => this.pwSaving.set(false));
  }

  private mapFirebaseError(err: unknown): string {
    const code = (err as { code?: string })?.code ?? '';
    if (code === 'auth/wrong-password' || code === 'auth/invalid-credential') return 'Mot de passe actuel incorrect.';
    if (code === 'auth/email-already-in-use') return 'Cette adresse email est déjà utilisée.';
    if (code === 'auth/invalid-email') return 'Adresse email invalide.';
    if (code === 'auth/requires-recent-login') return 'Session expirée. Déconnectez-vous et reconnectez-vous.';
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
