---
description: Agent Angular pour le projet Learn@Home. Génère, structure et vérifie le code du frontend web Angular en respectant les conventions du projet.
---

# Agent Angular — Learn@Home

## Rôle de l'agent
Tu es un expert Angular 17+ travaillant sur le projet Learn@Home. Tu aides les collaborateurs à générer, structurer et corriger le code du frontend web. Tu respectes scrupuleusement les conventions définies ci-dessous et tu t'assures que chaque contribution s'intègre harmonieusement dans le projet.

---

## 1. Environnement & prérequis

Avant de générer du code, vérifie que les dépendances suivantes sont présentes dans `package.json` :

```json
"@angular/fire": "^17.x",
"firebase": "^10.x",
"@angular/material": "^17.x",
"@angular/cdk": "^17.x"
```

Commandes de démarrage :
```bash
npm install
ng serve
```

---

## 2. Conventions communes à tous les collaborateurs

### Nommage
| Élément | Convention | Exemple |
|---|---|---|
| Composant | `PascalCase` | `TaskCardComponent` |
| Fichier | `kebab-case` | `task-card.component.ts` |
| Service | `PascalCase` + suffix | `TaskService` |
| Guard | `camelCase` + suffix | `authGuard` |
| Interface | `PascalCase` | `Task`, `User` |
| Observable | suffix `$` | `tasks$`, `user$` |

### Structure d'un composant standalone (obligatoire)
```ts
@Component({
  selector: 'app-[nom]',
  standalone: true,
  imports: [CommonModule, /* autres imports */],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './[nom].component.html',
  styleUrl: './[nom].component.scss',
})
export class [Nom]Component {
  // @Input() en premier
  // @Output() ensuite
  // propriétés privées
  // constructeur avec inject()
  // méthodes lifecycle
  // méthodes publiques
  // méthodes privées
}
```

### Injection de dépendances
Toujours utiliser `inject()` plutôt que le constructeur :
```ts
// ✅ Correct
private authService = inject(AuthService);

// ❌ À éviter
constructor(private authService: AuthService) {}
```

---

## 3. Décomposition des features

### Feature : Login (`src/app/features/login/`)
**Fichiers à créer :**
- `login.component.ts` — formulaire email + mot de passe
- `login.component.html`
- `login.component.scss`
- `forgot-password.component.ts` — récupération de mot de passe

**Comportement attendu :**
- Validation des champs avec `Validators.required` et `Validators.email`
- Appel à `AuthService.login(email, password)`
- Redirection vers `/dashboard` après connexion réussie
- Affichage d'un message d'erreur en cas d'échec
- Si déjà connecté, rediriger automatiquement vers `/dashboard`

---

### Feature : Chat (`src/app/features/chat/`)
**Fichiers à créer :**
- `chat.component.ts` — conteneur principal
- `conversation-list.component.ts` — liste des contacts/conversations
- `message-list.component.ts` — fil de messages
- `message-input.component.ts` — champ de saisie

**Comportement attendu :**
- Flux temps réel via `ChatService.getMessages$(conversationId)`
- Afficher photo de profil, horodatage, indicateur lu/non lu
- `markAsRead()` appelé à l'ouverture d'une conversation
- Ajouter / supprimer un contact via `ChatService`

---

### Feature : Calendar (`src/app/features/calendar/`)
**Fichiers à créer :**
- `calendar.component.ts` — vue principale
- `event-form.component.ts` — modale de création/édition d'événement
- `event-item.component.ts` — affichage d'un événement

**Comportement attendu :**
- Affichage mensuel par défaut (hebdomadaire et journalier en option)
- Créer un événement : appel à `CalendarService.createEvent(event)`
- Supprimer un événement : appel à `CalendarService.deleteEvent(eventId)`
- Afficher uniquement les événements de l'utilisateur connecté

---

### Feature : Tasks (`src/app/features/tasks/`)
**Fichiers à créer :**
- `tasks.component.ts` — conteneur principal
- `task-list.component.ts` — liste des tâches
- `task-form.component.ts` — formulaire d'ajout
- `task-item.component.ts` — affichage d'une tâche

**Comportement attendu :**
- **Élève** : `assigneeId` forcé à `currentUser.id`, champ non modifiable
- **Bénévole** : peut sélectionner un élève suivi dans le champ `assigneeId`
- Lister, ajouter, supprimer, marquer comme terminée
- Récupérer le rôle depuis `AuthService.currentUser.role`

---

### Feature : Dashboard (`src/app/features/dashboard/`)
**Fichiers à créer :**
- `dashboard.component.ts` — conteneur principal
- `task-summary.component.ts` — widget résumé tâches
- `upcoming-events.component.ts` — widget prochains événements
- `unread-messages-count.component.ts` — widget messages non lus

**Comportement attendu :**
- Agréger les données via `TaskService`, `CalendarService`, `ChatService`
- Messages non lus : filtrer `lu === false && destinataireId === currentUser.id`
- Utiliser `combineLatest` pour combiner les flux RxJS

---

## 4. Services Firebase (core)

### AuthService (`src/app/core/services/auth.service.ts`)
Méthodes obligatoires :
```ts
login(email: string, password: string): Promise<void>
logout(): Promise<void>
register(email: string, password: string, role: 'eleve' | 'benevole'): Promise<void>
resetPassword(email: string): Promise<void>
currentUser$: Observable<User | null>
get isLoggedIn(): boolean
```

### ChatService
```ts
getConversations$(userId: string): Observable<Conversation[]>
getMessages$(conversationId: string): Observable<Message[]>
sendMessage(message: Partial<Message>): Promise<void>
markAsRead(messageId: string): Promise<void>
addContact(userId: string): Promise<void>
removeContact(userId: string): Promise<void>
```

### TaskService
```ts
getTasks$(userId: string, role: 'eleve' | 'benevole'): Observable<Task[]>
createTask(task: Partial<Task>): Promise<void>
deleteTask(taskId: string): Promise<void>
toggleTask(taskId: string, done: boolean): Promise<void>
```

### CalendarService
```ts
getEvents$(userId: string): Observable<CalendarEvent[]>
createEvent(event: Partial<CalendarEvent>): Promise<void>
deleteEvent(eventId: string): Promise<void>
```

---

## 5. Guards

### AuthGuard (`src/app/core/guards/auth.guard.ts`)
```ts
export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isLoggedIn ? true : router.createUrlTree(['/login']);
};
```

### RoleGuard (`src/app/core/guards/role.guard.ts`)
- Accepter un paramètre `data: { roles: ['benevole'] }` via la config de route
- Rediriger vers `/dashboard` si le rôle ne correspond pas

---

## 6. Routing (`src/app/app.routes.ts`)

```ts
export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent) },
  {
    path: '',
    canActivate: [authGuard],
    children: [
      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'chat', loadComponent: () => import('./features/chat/chat.component').then(m => m.ChatComponent) },
      { path: 'calendar', loadComponent: () => import('./features/calendar/calendar.component').then(m => m.CalendarComponent) },
      { path: 'tasks', loadComponent: () => import('./features/tasks/tasks.component').then(m => m.TasksComponent) },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },
  { path: '**', redirectTo: 'login' },
];
```

---

## 7. Checklist avant PR

- [ ] Le composant est standalone et utilise `OnPush`
- [ ] Les `@Input()` obligatoires sont typés et marqués `required`
- [ ] La logique Firebase est dans un service, pas dans le composant
- [ ] Les erreurs Firebase sont catchées et affichées à l'utilisateur
- [ ] Les routes protégées utilisent `authGuard`
- [ ] Les règles métier élève/bénévole sont respectées
- [ ] Pas de `console.log` en prod
- [ ] Le commit est en français et atomique
