// Seed script — crée des comptes bénévoles dans Firebase Auth + Firestore
// Usage : node scripts/seed-benevoles.mjs

import { initializeApp } from 'firebase/app';
import { getAuth, createUserWithEmailAndPassword } from 'firebase/auth';
import { getFirestore, doc, setDoc, serverTimestamp } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyD0SHKR2QnKzVzWYSARJCmjyTaTT28p-LE',
  authDomain: 'learnathome-fade2.firebaseapp.com',
  projectId: 'learnathome-fade2',
  messagingSenderId: '819153036060',
  appId: '1:819153036060:web:a17b3496425af4502610d9',
};

const benevoles = [
  { prenom: 'Alice',   nom: 'Martin',   email: 'alice.martin@benevole.fr',   password: 'Benevole123!' },
  { prenom: 'Thomas',  nom: 'Dubois',   email: 'thomas.dubois@benevole.fr',  password: 'Benevole123!' },
  { prenom: 'Sophie',  nom: 'Bernard',  email: 'sophie.bernard@benevole.fr', password: 'Benevole123!' },
  { prenom: 'Lucas',   nom: 'Moreau',   email: 'lucas.moreau@benevole.fr',   password: 'Benevole123!' },
  { prenom: 'Emma',    nom: 'Petit',    email: 'emma.petit@benevole.fr',     password: 'Benevole123!' },
];

const app  = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db   = getFirestore(app);

for (const b of benevoles) {
  try {
    const cred = await createUserWithEmailAndPassword(auth, b.email, b.password);
    await setDoc(doc(db, `users/${cred.user.uid}`), {
      prenom: b.prenom,
      nom:    b.nom,
      email:  b.email,
      role:   'benevole',
      createdAt: serverTimestamp(),
    });
    console.log(`✅  ${b.prenom} ${b.nom} (${b.email})`);
  } catch (err) {
    if (err.code === 'auth/email-already-in-use') {
      console.warn(`⚠️   ${b.email} existe déjà — ignoré`);
    } else {
      console.error(`❌  ${b.email}`, err.message);
    }
  }
}

console.log('\nTerminé.');
process.exit(0);
