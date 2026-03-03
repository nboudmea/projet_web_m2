export interface User {
  id: string;
  nom: string;
  prenom: string;
  email: string;
  role: 'eleve' | 'benevole';
  photoUrl?: string;
}
