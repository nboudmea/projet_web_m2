---
description: Agent Flutter pour le projet Learn@Home. Génère, structure et vérifie le code du frontend mobile Flutter en respectant les conventions du projet.
---

# Agent Flutter — Learn@Home

## Rôle de l'agent
Tu es un expert Flutter travaillant sur le projet Learn@Home. Tu aides les collaborateurs à générer, structurer et corriger le code du frontend mobile. Tu respectes scrupuleusement les conventions définies ci-dessous et tu t'assures que chaque contribution s'intègre harmonieusement dans le projet.

---

## 1. Environnement & prérequis

Vérifie que les dépendances suivantes sont présentes dans `pubspec.yaml` :

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  go_router: ^13.x
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x
  firebase_storage: ^12.x
  intl: ^0.19.x

dev_dependencies:
  riverpod_generator: ^2.x
  build_runner: ^2.x
```

Commandes de démarrage :
```bash
flutter pub get
flutter run
```

---

## 2. Conventions communes à tous les collaborateurs

### Nommage
| Élément | Convention | Exemple |
|---|---|---|
| Classe / Widget | `PascalCase` | `TaskCard`, `ChatScreen` |
| Fichier | `snake_case` | `task_card.dart`, `chat_screen.dart` |
| Variable / méthode | `camelCase` | `currentUser`, `fetchTasks()` |
| Provider | `camelCase` + suffix | `tasksProvider`, `authStateProvider` |
| Constante | `camelCase` | `maxMessageLength` |

### Structure d'un widget (obligatoire)
```dart
// Préférer StatelessWidget + ConsumerWidget si besoin de Riverpod
class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(task.titre),
      ),
    );
  }
}
```

### Règle `const`
Utiliser `const` partout où c'est possible pour optimiser les rebuilds :
```dart
// ✅ Correct
const SizedBox(height: 16),
const Text('Mes tâches'),

// ❌ À éviter
SizedBox(height: 16),
Text('Mes tâches'),
```

### Gestion des états async (Riverpod)
Toujours gérer les trois états avec `AsyncValue.when` :
```dart
ref.watch(tasksProvider).when(
  data: (tasks) => TaskList(tasks: tasks),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => ErrorMessage(message: e.toString()),
);
```

---

## 3. Décomposition des features

### Feature : Login (`lib/features/login/`)
**Fichiers à créer :**
- `screens/login_screen.dart` — formulaire email + mot de passe
- `screens/forgot_password_screen.dart` — récupération de mot de passe
- `widgets/login_form.dart` — widget formulaire isolé

**Comportement attendu :**
- Validation des champs (email non vide, format email valide, mot de passe ≥ 6 caractères)
- Appel à `AuthService.login(email, password)`
- Redirection vers `/dashboard` après connexion réussie
- Affichage d'un `SnackBar` en cas d'erreur Firebase
- Si déjà connecté au démarrage, rediriger automatiquement via GoRouter `redirect`

---

### Feature : Chat (`lib/features/chat/`)
**Fichiers à créer :**
- `screens/chat_screen.dart` — écran principal avec liste des conversations
- `screens/conversation_screen.dart` — fil de messages d'une conversation
- `widgets/message_bubble.dart` — bulle de message (photo, texte, horodatage, lu/non lu)
- `widgets/message_input.dart` — champ de saisie + bouton envoi
- `widgets/contact_list_item.dart` — élément de liste de contacts

**Comportement attendu :**
- Flux temps réel via `StreamProvider` sur la collection Firestore `messages`
- Afficher photo de profil (`CircleAvatar`), horodatage (`intl.DateFormat`), icône lu/non lu
- `ChatService.markAsRead()` appelé à l'ouverture d'une conversation
- Bouton pour ajouter / supprimer un contact

---

### Feature : Calendar (`lib/features/calendar/`)
**Fichiers à créer :**
- `screens/calendar_screen.dart` — vue principale
- `widgets/event_card.dart` — affichage d'un événement
- `widgets/event_form.dart` — formulaire création/suppression d'événement (BottomSheet ou Dialog)

**Comportement attendu :**
- Affichage de la liste des événements à venir triés par date
- Créer un événement : appel à `CalendarService.createEvent(event)`
- Supprimer un événement : appel à `CalendarService.deleteEvent(eventId)`
- Afficher uniquement les événements de l'utilisateur connecté

---

### Feature : Tasks (`lib/features/tasks/`)
**Fichiers à créer :**
- `screens/tasks_screen.dart` — conteneur principal
- `widgets/task_list.dart` — liste des tâches
- `widgets/task_item.dart` — élément de tâche avec checkbox et bouton supprimer
- `widgets/task_form.dart` — formulaire d'ajout de tâche (BottomSheet)

**Comportement attendu :**
- **Élève** : `assigneeId` forcé à `currentUser.id`, pas de sélecteur d'élève
- **Bénévole** : `DropdownButton` pour sélectionner un élève suivi
- Lister, ajouter, supprimer, cocher comme terminée
- Récupérer le rôle depuis `authStateProvider`

---

### Feature : Dashboard (`lib/features/dashboard/`)
**Fichiers à créer :**
- `screens/dashboard_screen.dart` — écran principal
- `widgets/task_summary_card.dart` — widget résumé des tâches
- `widgets/upcoming_events_card.dart` — widget prochains événements
- `widgets/unread_messages_badge.dart` — widget compteur messages non lus

**Comportement attendu :**
- Utiliser plusieurs providers en parallèle : `tasksProvider`, `eventsProvider`, `unreadMessagesProvider`
- Messages non lus : filtrer `lu == false && destinataireId == currentUser.id`
- Chaque widget doit gérer son propre état de chargement/erreur

---

## 4. Services Firebase (`lib/core/services/`)

### AuthService (`auth_service.dart`)
Méthodes obligatoires :
```dart
Future<void> login(String email, String password);
Future<void> logout();
Future<void> register(String email, String password, String role);
Future<void> resetPassword(String email);
Stream<User?> get authStateChanges;
AppUser? get currentUser;
```

### ChatService (`chat_service.dart`)
```dart
Stream<List<Message>> watchMessages(String conversationId);
Stream<List<AppUser>> watchContacts(String userId);
Future<void> sendMessage(Message message);
Future<void> markAsRead(String messageId);
Future<void> addContact(String userId);
Future<void> removeContact(String userId);
```

### TaskService (`task_service.dart`)
```dart
Stream<List<Task>> watchTasks(String userId, String role);
Future<void> createTask(Task task);
Future<void> deleteTask(String taskId);
Future<void> toggleTask(String taskId, bool done);
```

### CalendarService (`calendar_service.dart`)
```dart
Stream<List<CalendarEvent>> watchEvents(String userId);
Future<void> createEvent(CalendarEvent event);
Future<void> deleteEvent(String eventId);
```

---

## 5. Providers Riverpod (`lib/core/`)

```dart
// Provider d'état d'authentification (Stream Firebase)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider utilisateur courant enrichi (depuis Firestore)
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return null;
  return ref.read(authServiceProvider).getUser(user.uid);
});

// Provider tâches (temps réel)
final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.read(taskServiceProvider).watchTasks(user.id, user.role);
});

// Provider messages non lus
final unreadMessagesProvider = StreamProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return Stream.value(0);
  return ref.read(chatServiceProvider).watchUnreadCount(user.id);
});
```

---

## 6. Navigation GoRouter (`lib/core/router/app_router.dart`)

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final onLogin = state.matchedLocation == '/login';
    if (!isLoggedIn && !onLogin) return '/login';
    if (isLoggedIn && onLogin) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
    GoRoute(path: '/chat/:id', builder: (_, state) => ConversationScreen(id: state.pathParameters['id']!)),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
  ],
);
```

---

## 7. Modèles de données Dart (`lib/core/models/`)

```dart
// user.dart
class AppUser {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String role; // 'eleve' | 'benevole'
  final String? photoUrl;

  factory AppUser.fromDoc(DocumentSnapshot doc) { /* ... */ }
  Map<String, dynamic> toMap() { /* ... */ }
}

// task.dart
class Task {
  final String id;
  final String titre;
  final String? description;
  final String assigneeId;
  final String createurId;
  final DateTime? dateEcheance;
  final bool terminee;

  factory Task.fromDoc(DocumentSnapshot doc) { /* ... */ }
  Map<String, dynamic> toMap() { /* ... */ }
}
```

---

## 8. Checklist avant PR

- [ ] Tous les widgets utilisent `const` là où c'est possible
- [ ] Les états async sont gérés avec `AsyncValue.when` (data / loading / error)
- [ ] La logique Firebase est dans un service, pas dans un widget
- [ ] Les erreurs sont affichées via `SnackBar` ou un widget dédié
- [ ] La navigation est gérée par GoRouter, pas par `Navigator.push` directement
- [ ] Les règles métier élève/bénévole sont respectées
- [ ] `flutter analyze` ne retourne aucune erreur ou warning
- [ ] Pas de `print()` en prod (utiliser un logger)
- [ ] Le commit est en français et atomique
