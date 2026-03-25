import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  Input,
  ViewChild,
  inject,
  signal,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Auth } from '@angular/fire/auth';
import { UserService } from '../../../core/services/user.service';

@Component({
  selector: 'app-avatar-upload',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './avatar-upload.component.html',
  styleUrl: './avatar-upload.component.scss',
})
export class AvatarUploadComponent {
  @Input() photoUrl?: string | null;
  @Input() prenom?: string;
  @Input() nom?: string;
  @Input() uid!: string;

  @ViewChild('fileInput') private fileInput!: ElementRef<HTMLInputElement>;

  private userService = inject(UserService);

  readonly uploading = signal(false);
  readonly error = signal<string | null>(null);

  get initials(): string {
    const p = (this.prenom ?? '').trim();
    const n = (this.nom ?? '').trim();
    return ((p[0] ?? '') + (n[0] ?? '')).toUpperCase() || '?';
  }

  openPicker(): void {
    this.fileInput.nativeElement.click();
  }

  onFileSelected(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      this.error.set('Le fichier doit être une image.');
      return;
    }

    this.error.set(null);
    this.uploading.set(true);

    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const base64 = this.compress(img, 128, 128, 0.75);
        this.userService
          .updatePhotoUrl(this.uid, base64)
          .catch(() => this.error.set('Échec de la sauvegarde.'))
          .finally(() => this.uploading.set(false));
      };
      img.src = e.target!.result as string;
    };
    reader.readAsDataURL(file);

    // Reset input pour permettre le même fichier
    (event.target as HTMLInputElement).value = '';
  }

  private compress(
    img: HTMLImageElement,
    maxW: number,
    maxH: number,
    quality: number
  ): string {
    const canvas = document.createElement('canvas');
    const scale = Math.min(maxW / img.width, maxH / img.height, 1);
    canvas.width = Math.round(img.width * scale);
    canvas.height = Math.round(img.height * scale);
    canvas.getContext('2d')!.drawImage(img, 0, 0, canvas.width, canvas.height);
    return canvas.toDataURL('image/jpeg', quality);
  }
}
