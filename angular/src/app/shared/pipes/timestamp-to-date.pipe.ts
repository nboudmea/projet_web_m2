import { Pipe, PipeTransform } from '@angular/core';

/**
 * Convertit une valeur dateEcheance (Date JS, Firestore Timestamp, string)
 * en Date JS exploitable par DatePipe.
 * Usage : {{ task.dateEcheance | timestampToDate | date:'d MMM yyyy' }}
 */
@Pipe({ name: 'timestampToDate', standalone: true, pure: true })
export class TimestampToDatePipe implements PipeTransform {
  transform(value: unknown): Date | null {
    if (!value) return null;
    if (value instanceof Date) return value;
    if (typeof (value as any).toDate === 'function') return (value as any).toDate();
    const d = new Date(value as string);
    return isNaN(d.getTime()) ? null : d;
  }
}
