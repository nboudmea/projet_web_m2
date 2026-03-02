# Copilot Instructions — Learn@Home

## Présentation du projet

**Learn@Home** est une association qui met en relation des enfants en difficulté scolaire et des bénévoles, en ligne. L'objectif est de permettre à tout élève, où qu'il soit, d'accéder à un soutien scolaire à distance.

Chaque élève inscrit sur le site a un tuteur bénévole qui lui est assigné. Le bénévole soutient l'élève dans son apprentissage à travers de courts rendez-vous hebdomadaires, au cours desquels il aide l'élève à réaliser ses devoirs et à s'organiser.

---

## Stack technique recommandée

### Frontend Web — Angular
- **Framework** : Angular (avec TypeScript)
- **Styles** : SCSS / Angular Material ou Tailwind CSS
- **Routing** : Angular Router
- **État global** : NgRx ou services Angular avec BehaviorSubject
- **HTTP** : HttpClient + Interceptors

### Frontend Mobile — Flutter
- **Framework** : Flutter (avec Dart)
- **État global** : Provider, Riverpod ou Bloc
- **Navigation** : GoRouter ou Navigator 2.0
- **HTTP** : Dio ou http package

### Backend / Auth & Base de données
- **Auth** : Firebase Authentication
- **Base de données** : Firestore (Firebase)
- **Stockage fichiers** : Firebase Storage (photos de profil, etc.)

---

## Structure du projet

### Projet Angular (Web)

```
src/
├── assets/                    # Images, icônes, polices
├── app/
│   ├── core/
│   │   ├── guards/            # AuthGuard, RoleGuard
│   │   ├── interceptors/      # HTTP interceptors (JWT, etc.)
│   │   ├── services/          # AuthService, ChatService, etc.
│   │   └── models/            # Interfaces TypeScript (User, Message, Task, etc.)
│   ├── shared/
│   │   └── components/        # Composants réutilisables (bouton, modal, etc.)
│   ├── features/
│   │   ├── login/             # Page de connexion
│   │   ├── chat/              # Interface de chat
│   │   ├── calendar/          # Page de calendrier
│   │   ├── tasks/             # Page de gestion des tâches
│   │   └── dashboard/         # Tableau de bord
│   ├── app.routes.ts
│   ├── app.component.ts
│   └── app.config.ts
├── environments/
│   ├── environment.ts
│   └── environment.prod.ts
└── main.ts
```

### Projet Flutter (Mobile)

```
lib/
├── core/
│   ├── services/              # AuthService, ChatService, etc.
│   ├── models/                # Classes Dart (User, Message, Task, etc.)
│   ├── router/                # GoRouter / routes
│   └── theme/                 # Thème de l'application
├── features/
│   ├── login/
│   │   ├── screens/
│   │   └── widgets/
│   ├── chat/
│   │   ├── screens/
│   │   └── widgets/
│   ├── calendar/
│   │   ├── screens/
│   │   └── widgets/
│   ├── tasks/
│   │   ├── screens/
│   │   └── widgets/
│   └── dashboard/
│       ├── screens/
│       └── widgets/
├── shared/
│   └── widgets/               # Widgets réutilisables
└── main.dart
```

---

## Pages à développer

### 1. Page de connexion (`/login`)

Accessible à tous (élèves et bénévoles). Toutes les autres pages sont protégées et nécessitent une authentification.

**Fonctionnalités requises :**
- Formulaire de connexion (email + mot de passe)
- Système de récupération de mot de passe oublié
- Lien vers une page de création de compte
- Validation des champs côté client
- Redirection automatique vers le tableau de bord si déjà connecté

---

### 2. Interface de chat (`/chat`)

Page de messagerie instantanée entre élèves et bénévoles.

**Fonctionnalités requises :**
- Discussion instantanée (temps réel)
- Historique des conversations
- Ajout et suppression de contacts
- Photo de profil de l'expéditeur affichée à côté de chaque message
- Indicateur de lecture (message lu / non lu)
- Horodatage de chaque message

---

### 3. Page de calendrier (`/calendar`)

Calendrier classique affichant les événements et rendez-vous de l'utilisateur connecté.

**Fonctionnalités requises :**
- Affichage mensuel / hebdomadaire / journalier
- Affichage des événements et rendez-vous planifiés
- Création et suppression d'événements

---

### 4. Page de gestion des tâches (`/tasks`)

Interface de to-do list avec gestion des rôles (élève vs bénévole).

**Fonctionnalités requises :**
- Lister les tâches
- Ajouter une tâche
- Supprimer une tâche
- **Règles métier :**
  - Un élève ne peut créer des tâches que pour lui-même
  - Un bénévole peut créer des tâches pour les élèves qu'il suit

---

### 5. Tableau de bord (`/dashboard`) — Page principale

Page d'accueil après connexion. Agrège les informations importantes des autres pages.

**Fonctionnalités requises :**
- Récapitulatif des tâches (to-do list issue de la page Tâches)
- Liste des prochains événements (issue du Calendrier)
- Compteur de messages non lus (issu du Chat)

---

## Règles de développement

### Authentification & sécurité
- Les routes `/chat`, `/calendar`, `/tasks`, `/dashboard` sont protégées : l'utilisateur doit être connecté.
- **Angular** : implémenter un `AuthGuard` et un `RoleGuard` avec `CanActivate`.
- **Flutter** : gérer la redirection via GoRouter `redirect` ou un `StreamBuilder` sur l'état d'auth.
- Distinguer les rôles : `eleve` et `benevole`.

### Composants / Widgets
- **Angular** : préférer les composants standalone (Angular 17+), documenter les `@Input()` / `@Output()`.
- **Flutter** : décomposer en petits widgets réutilisables, préférer les `StatelessWidget` quand possible.
- Extraire la logique métier dans des services (Angular) ou providers/blocs (Flutter).

### Style & UX
- Interface responsive (mobile-first).
- Utiliser des feedbacks visuels (chargement, erreurs, succès).
- Messages d'erreur clairs et accessibles.

### Code
- Ne pas dupliquer la logique : extraire dans des services ou helpers.
- Nommer les variables et fonctions en français ou en anglais de façon cohérente sur l'ensemble du projet.
- Commits en français, clairs et atomiques.

---

## Modèles de données (types TypeScript)

```ts
// Utilisateur
interface User {
  id: string;
  nom: string;
  prenom: string;
  email: string;
  role: 'eleve' | 'benevole';
  photoUrl?: string;
}

// Message
interface Message {
  id: string;
  expediteurId: string;
  destinataireId: string;
  contenu: string;
  dateEnvoi: Date;
  lu: boolean;
}

// Tâche
interface Task {
  id: string;
  titre: string;
  description?: string;
  assigneeId: string;       // ID de l'élève concerné
  createurId: string;       // ID du créateur (élève ou bénévole)
  dateEcheance?: Date;
  terminee: boolean;
}

// Événement calendrier
interface CalendarEvent {
  id: string;
  titre: string;
  description?: string;
  debut: Date;
  fin: Date;
  participantsIds: string[];
}
```

---

## Comportement attendu par rôle

| Fonctionnalité         | Élève                          | Bénévole                              |
|------------------------|--------------------------------|---------------------------------------|
| Créer une tâche        | Pour lui-même uniquement       | Pour lui-même ou ses élèves           |
| Voir les tâches        | Ses propres tâches             | Ses tâches + tâches de ses élèves     |
| Chat                   | Avec son/ses bénévoles         | Avec ses élèves                       |
| Calendrier             | Ses événements                 | Ses événements + RDV avec ses élèves  |
| Tableau de bord        | Résumé personnel               | Résumé personnel + activité élèves    |
