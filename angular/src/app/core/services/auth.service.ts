import { inject, Injectable } from '@angular/core';
import { Auth, signInWithEmailAndPassword, signOut, sendPasswordResetEmail, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Firestore, doc, setDoc, serverTimestamp } from '@angular/fire/firestore';
import { from, Observable } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private auth = inject(Auth); // récupère la connexion Firebase Auth injectée dans app.config.ts
  private firestore = inject(Firestore); // récupère la connexion à la base de données Firestore injectée dans app.config.ts

  login(email: string, password: string): Promise<void> {
    return signInWithEmailAndPassword(this.auth, email, password)
      .then(() => {
        console.log('Connexion réussie');
      })
      .catch(error => {
        console.error('Erreur de connexion:', error);
        throw error;
      });
  }

  logout(): Promise<void> {
    return signOut(this.auth);
  }

  register(email: string, password: string, role: 'eleve' | 'benevole'): Promise<void> {
    return createUserWithEmailAndPassword(this.auth, email, password)
      .then(userCredential => {
        const user = userCredential.user;
        const userDoc = doc(this.firestore, `users/${user.uid}`);
        return setDoc(userDoc, {
          email: user.email,
          role: role,
          createdAt: serverTimestamp(),
        });
      })
      .catch(error => {
        console.error('Erreur d\'inscription:', error);
        throw error;
      });
  }

  resetPassword(email: string): Promise<void> {
    return sendPasswordResetEmail(this.auth, email);
  }

  get isLoggedIn(): boolean {
    return !!this.auth.currentUser;
  }
}
