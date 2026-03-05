export interface CalendarEvent {
  id: string;
  titre: string;
  description?: string;
  debut: Date;
  fin: Date;
  participantsIds: string[];
  createurId: string;
}
