export interface Task {
  id: string;
  titre: string;
  description?: string;    
  assigneeId: string;       // ID de l'élève concerné
  createurId: string;       // ID du créateur (élève ou bénévole)
  dateEcheance?: Date;      
  terminee: boolean;
}