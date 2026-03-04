// Migration — assigne un bénévole aux élèves qui n'en ont pas encore
// Usage : node scripts/assign-benevoles.mjs

import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

initializeApp({
  credential: applicationDefault(),
  projectId: 'learnathome-fade2',
});

const db = getFirestore();

// 1. Récupère tous les bénévoles
const bSnapshot = await db.collection('users').where('role', '==', 'benevole').get();
const benevoles = bSnapshot.docs.map(d => ({ id: d.id, ...d.data() }));

if (benevoles.length === 0) {
  console.error('❌ Aucun bénévole trouvé en base.');
  process.exit(1);
}

// 2. Compte les élèves déjà assignés par bénévole
const eSnapshot = await db.collection('users').where('role', '==', 'eleve').get();
const countMap = new Map();
eSnapshot.forEach(d => {
  const bid = d.data().benevoleId;
  if (bid) countMap.set(bid, (countMap.get(bid) ?? 0) + 1);
});

console.log(`📊 ${benevoles.length} bénévole(s), ${eSnapshot.size} élève(s) au total\n`);

// 3. Sélectionne le bénévole le moins chargé avec de la place (< 3 élèves)
function pickBenevole() {
  const available = benevoles
    .filter(b => (countMap.get(b.id) ?? 0) < 3)
    .sort((a, b) => (countMap.get(a.id) ?? 0) - (countMap.get(b.id) ?? 0));
  return available.length > 0 ? available[0] : null;
}

// 4. Assigne les élèves sans bénévole
let assigned = 0;
let skipped  = 0;

for (const snap of eSnapshot.docs) {
  const data = snap.data();
  if (data.benevoleId) {
    console.log(`⏭️   ${data.email} — déjà assigné`);
    skipped++;
    continue;
  }

  const benevole = pickBenevole();
  if (!benevole) {
    console.warn(`⚠️  Aucun bénévole disponible pour ${data.email} — tous ont 3 élèves.`);
    continue;
  }

  await db.doc(`users/${snap.id}`).update({ benevoleId: benevole.id });
  countMap.set(benevole.id, (countMap.get(benevole.id) ?? 0) + 1);
  console.log(`✅  ${data.email} → ${benevole.prenom ?? ''} ${benevole.nom ?? ''} (${benevole.email})`);
  assigned++;
}

console.log(`\nTerminé : ${assigned} assigné(s), ${skipped} déjà assigné(s).`);
process.exit(0);
