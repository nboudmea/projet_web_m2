export interface User {
  id: string;
  nom: string;
  prenom: string;
  email: string;
  role: 'eleve' | 'benevole';
  photoUrl?: string;
  /** Renseigné sur le document d'un élève : UID du bénévole qui le suit */
  benevoleId?: string;
}
