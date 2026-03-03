import { inject, Injectable } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  addDoc,
  deleteDoc,
  doc,
  updateDoc,
  query,
  where,
  serverTimestamp,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { Task } from '../models/task.model';

@Injectable({ providedIn: 'root' })
export class TaskService {
  private firestore = inject(Firestore);

  /**
   * Tâches assignées à un élève (assigneeId === userId)
   */
  getTasksEleve$(eleveId: string): Observable<Task[]> {
    const q = query(
      collection(this.firestore, 'tasks'),
      where('assigneeId', '==', eleveId)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Task[]>;
  }

  /**
   * Tâches créées par un bénévole (createurId === userId)
   */
  getTasksBenevole$(benevoleId: string): Observable<Task[]> {
    const q = query(
      collection(this.firestore, 'tasks'),
      where('createurId', '==', benevoleId)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Task[]>;
  }

  createTask(task: Omit<Task, 'id'>): Promise<void> {
    return addDoc(collection(this.firestore, 'tasks'), {
      ...task,
      createdAt: serverTimestamp(),
    }).then(() => undefined);
  }

  deleteTask(taskId: string): Promise<void> {
    return deleteDoc(doc(this.firestore, `tasks/${taskId}`));
  }

  toggleTask(taskId: string, terminee: boolean): Promise<void> {
    return updateDoc(doc(this.firestore, `tasks/${taskId}`), { terminee });
  }
}
