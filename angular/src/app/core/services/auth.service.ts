import { inject, Injectable } from '@angular/core';
import { Auth, signInWithEmailAndPassword, signOut, sendPasswordResetEmail, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Firestore, doc, setDoc, serverTimestamp } from '@angular/fire/firestore';
import { from, Observable } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private auth = inject(Auth);
  private firestore = inject(Firestore);

  // TODO: implémenter login()
  login(email: string, password: string): Promise<void> {
    return Promise.resolve();
  }

  // TODO: implémenter logout()
  logout(): Promise<void> {
    return Promise.resolve();
  }

  // TODO: implémenter register()
  register(email: string, password: string, role: 'eleve' | 'benevole'): Promise<void> {
    return Promise.resolve();
  }

  // TODO: implémenter resetPassword()
  resetPassword(email: string): Promise<void> {
    return Promise.resolve();
  }

  get isLoggedIn(): boolean {
    return !!this.auth.currentUser;
  }
}
