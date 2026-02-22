/**
 * ===========================================
 * TESTS SIMPLES POUR L'API
 * ===========================================
 *
 * Pourquoi des tests ?
 * → Le CI/CD va les exécuter automatiquement
 * → Si les tests échouent, le déploiement est bloqué
 * → Ça évite de déployer du code cassé en production
 */

const assert = require('assert');

console.log('🧪 Lancement des tests...\n');

let testsPassed = 0;
let testsFailed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`✅ ${name}`);
    testsPassed++;
  } catch (error) {
    console.log(`❌ ${name}`);
    console.log(`   Erreur: ${error.message}`);
    testsFailed++;
  }
}

// === TESTS ===

test('Le serveur exporte une application Express', () => {
  const app = require('./server.js');
  assert(app !== undefined, 'App non définie');
  assert(typeof app.listen === 'function', 'App n\'est pas une app Express');
});

test('Les variables d\'environnement sont accessibles', () => {
  // En DevOps, on configure l'app via des variables d'environnement
  const port = process.env.PORT || 3000;
  assert(typeof port === 'number' || typeof port === 'string', 'PORT invalide');
});

test('JSON.parse fonctionne (test basique)', () => {
  const data = JSON.parse('{"status": "ok"}');
  assert(data.status === "ok", 'JSON mal parsé');
});

// === RÉSUMÉ ===

console.log('\n-----------------------------------');
console.log(`Tests passés: ${testsPassed}`);
console.log(`Tests échoués: ${testsFailed}`);
console.log('-----------------------------------');

// Exit code pour CI/CD
// 0 = succès, 1 = échec
process.exit(testsFailed > 0 ? 1 : 0);
