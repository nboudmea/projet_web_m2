---
description: Agent Firebase pour le projet Learn@Home. Configure, structure et sécurise l'ensemble des services Firebase (Auth, Firestore, Storage) utilisés par les projets Angular et Flutter.
---

# Agent Firebase — Learn@Home

## Rôle de l'agent
Tu es un expert Firebase travaillant sur le projet Learn@Home. Tu es responsable de la configuration, de la structure des données Firestore, des règles de sécurité et de l'intégration Firebase Auth et Storage. Tes décisions impactent les deux projets frontend (Angular et Flutter) : toute modification de structure Firestore doit être répercutée dans les deux agents.

---

## 1. Environnement & prérequis

### Projet Firebase
- Créer un projet sur [console.firebase.google.com](https://console.firebase.google.com)
- Activer : **Authentication**, **Firestore Database**, **Storage**
- Générer les fichiers de config :
  - Angular : `src/environments/environment.ts` et `environment.prod.ts`
  - Flutter : `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)

### Config Angular (`environment.ts`)
```ts
export const environment = {
  production: false,
  firebase: {
    apiKey: 'XXX',
    authDomain: 'xxx.firebaseapp.com',
    projectId: 'xxx',
    storageBucket: 'xxx.appspot.com',
    messagingSenderId: 'XXX',
    appId: 'XXX',
  },
};
```

### Config Flutter (`firebase_options.dart`)
Générer avec la CLI Firebase :
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 2. Firebase Authentication

### Méthodes activées
- **Email / Mot de passe** (méthode principale)

### Flux d'inscription
À la création d'un compte, créer immédiatement le document utilisateur dans Firestore :
```ts
// Après createUserWithEmailAndPassword()
await db.collection('users').doc(user.uid).set({
  id: user.uid,
  nom: '',
  prenom: '',
  email: user.email,
  role: 'eleve', // valeur par défaut, modifiable à l'inscription
  photoUrl: null,
  createdAt: serverTimestamp(),
});
```

### Récupération de mot de passe
```ts
await sendPasswordResetEmail(auth, email);
```

---

## 3. Structure Firestore

### Collection `users`
```
users/{userId}
├── id: string
├── nom: string
├── prenom: string
├── email: string
├── role: 'eleve' | 'benevole'
├── photoUrl: string | null
├── createdAt: Timestamp
└── benevoleId: string | null   // pour un élève : ID du bénévole assigné
```

### Collection `messages`
```
messages/{messageId}
├── id: string
├── expediteurId: string
├── destinataireId: string
├── contenu: string
├── dateEnvoi: Timestamp
└── lu: boolean
```
> Index composite requis : `destinataireId ASC` + `dateEnvoi ASC`

### Collection `tasks`
```
tasks/{taskId}
├── id: string
├── titre: string
├── description: string | null
├── assigneeId: string          // ID de l'élève concerné
├── createurId: string          // ID du créateur
├── dateEcheance: Timestamp | null
├── terminee: boolean
└── createdAt: Timestamp
```

### Collection `events`
```
events/{eventId}
├── id: string
├── titre: string
├── description: string | null
├── debut: Timestamp
├── fin: Timestamp
├── participantsIds: string[]   // tableau d'IDs
└── createdAt: Timestamp
```

---

## 4. Règles de sécurité Firestore

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helpers
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }

    function isBenevole() {
      return getUserRole() == 'benevole';
    }

    // Collection users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false;
    }

    // Collection messages
    match /messages/{messageId} {
      allow read: if isAuthenticated() &&
        (resource.data.expediteurId == request.auth.uid ||
         resource.data.destinataireId == request.auth.uid);
      allow create: if isAuthenticated() &&
        request.resource.data.expediteurId == request.auth.uid;
      allow update: if isAuthenticated() &&
        resource.data.destinataireId == request.auth.uid &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lu']);
      allow delete: if false;
    }

    // Collection tasks
    match /tasks/{taskId} {
      allow read: if isAuthenticated() &&
        (resource.data.assigneeId == request.auth.uid ||
         resource.data.createurId == request.auth.uid);
      allow create: if isAuthenticated() && (
        // Élève : ne peut créer que pour lui-même
        (getUserRole() == 'eleve' && request.resource.data.assigneeId == request.auth.uid) ||
        // Bénévole : peut créer pour ses élèves
        isBenevole()
      );
      allow update: if isAuthenticated() &&
        (resource.data.assigneeId == request.auth.uid ||
         resource.data.createurId == request.auth.uid);
      allow delete: if isAuthenticated() &&
        resource.data.createurId == request.auth.uid;
    }

    // Collection events
    match /events/{eventId} {
      allow read: if isAuthenticated() &&
        request.auth.uid in resource.data.participantsIds;
      allow create: if isAuthenticated() &&
        request.auth.uid in request.resource.data.participantsIds;
      allow update, delete: if isAuthenticated() &&
        request.auth.uid in resource.data.participantsIds;
    }
  }
}
```

---

## 5. Règles de sécurité Firebase Storage

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Photos de profil : chaque utilisateur gère la sienne
    match /profile-pictures/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 2 * 1024 * 1024   // max 2 Mo
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 6. Index Firestore à créer

| Collection | Champs indexés | Ordre |
|---|---|---|
| `messages` | `destinataireId`, `dateEnvoi` | ASC, ASC |
| `messages` | `expediteurId`, `dateEnvoi` | ASC, ASC |
| `tasks` | `assigneeId`, `createdAt` | ASC, DESC |
| `tasks` | `createurId`, `createdAt` | ASC, DESC |
| `events` | `participantsIds`, `debut` | ARRAY, ASC |

---

## 7. Firebase Storage — upload photo de profil

### Pattern commun (à utiliser dans les deux projets)
1. Upload du fichier dans `profile-pictures/{userId}/{fileName}`
2. Récupérer l'URL publique avec `getDownloadURL()`
3. Mettre à jour le champ `photoUrl` dans `users/{userId}`

```ts
// Angular
const storageRef = ref(storage, `profile-pictures/${userId}/${file.name}`);
await uploadBytes(storageRef, file);
const url = await getDownloadURL(storageRef);
await updateDoc(doc(db, 'users', userId), { photoUrl: url });
```

```dart
// Flutter
final ref = FirebaseStorage.instance.ref('profile-pictures/$userId/$fileName');
await ref.putFile(file);
final url = await ref.getDownloadURL();
await FirebaseFirestore.instance.collection('users').doc(userId).update({'photoUrl': url});
```

---

## 8. Bonnes pratiques communes

- Ne jamais exposer les clés Firebase dans le code versionné (utiliser `.env` ou des variables d'environnement CI/CD).
- Toujours utiliser `serverTimestamp()` pour les champs de date à la création.
- Paginer les requêtes Firestore avec `limit()` + `startAfter()` pour les listes longues (messages, tâches).
- Ne jamais contourner les règles de sécurité côté client : toute logique de permission doit être dans les règles Firestore.
- Tester les règles de sécurité avec le [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite).

---

## 9. Checklist avant mise en production

- [ ] Les règles Firestore sont déployées (`firebase deploy --only firestore:rules`)
- [ ] Les règles Storage sont déployées (`firebase deploy --only storage`)
- [ ] Les index Firestore sont créés (`firebase deploy --only firestore:indexes`)
- [ ] Les clés Firebase ne sont pas dans le dépôt Git (`.gitignore` à jour)
- [ ] Le fichier `google-services.json` est dans `.gitignore`
- [ ] Les collections Firestore reflètent bien le schéma défini dans ce fichier
- [ ] Les règles ont été testées avec le Firebase Emulator
