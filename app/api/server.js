/**
 * ===========================================
 * PAPIER.NET - API BACKEND
 * ===========================================
 *
 * C'est quoi ce fichier ?
 * → C'est le serveur backend qui gère les données
 * → Il expose une API REST (des URLs qui renvoient du JSON)
 *
 * Concepts clés :
 * - Express = framework web Node.js (comme Flask en Python)
 * - API REST = URLs qui font des actions (GET = lire, POST = créer, etc.)
 * - JSON = format de données universel
 */

const express = require('express');
const cors = require('cors');

// Création de l'application Express
const app = express();

// === MIDDLEWARES ===
// Middleware = fonction qui s'exécute AVANT chaque requête

app.use(cors());           // Permet les requêtes depuis le frontend
app.use(express.json());   // Permet de lire le JSON dans les requêtes

// === BASE DE DONNÉES SIMPLIFIÉE ===
// En vrai on utiliserait PostgreSQL/MongoDB, mais pour apprendre le DevOps
// on garde ça simple avec un tableau en mémoire

let papiers = [
  {
    id: 1,
    nom: "Déclaration impôts",
    organisme: "impots.gouv.fr",
    statut: "a_faire",
    deadline: "2024-05-31"
  },
  {
    id: 2,
    nom: "Actualisation Pôle Emploi",
    organisme: "pole-emploi.fr",
    statut: "a_faire",
    deadline: "2024-02-28"
  },
  {
    id: 3,
    nom: "Résiliation Netflix",
    organisme: "netflix.com",
    statut: "fait",
    deadline: null
  }
];

// === ROUTES API ===
// Route = URL + méthode HTTP + fonction à exécuter

// Health check - TRÈS IMPORTANT pour DevOps
// C'est comme ça que Docker/Kubernetes vérifient si l'app est vivante
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// GET /api/papiers - Récupérer tous les papiers
app.get('/api/papiers', (req, res) => {
  res.json(papiers);
});

// GET /api/papiers/:id - Récupérer un papier par son ID
app.get('/api/papiers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const papier = papiers.find(p => p.id === id);

  if (!papier) {
    return res.status(404).json({ error: 'Papier non trouvé' });
  }

  res.json(papier);
});

// POST /api/papiers - Créer un nouveau papier
app.post('/api/papiers', (req, res) => {
  const nouveauPapier = {
    id: papiers.length + 1,
    nom: req.body.nom,
    organisme: req.body.organisme,
    statut: 'a_faire',
    deadline: req.body.deadline || null
  };

  papiers.push(nouveauPapier);
  res.status(201).json(nouveauPapier);
});

// PATCH /api/papiers/:id - Mettre à jour le statut
app.patch('/api/papiers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const papier = papiers.find(p => p.id === id);

  if (!papier) {
    return res.status(404).json({ error: 'Papier non trouvé' });
  }

  // Met à jour seulement les champs envoyés
  if (req.body.statut) papier.statut = req.body.statut;
  if (req.body.nom) papier.nom = req.body.nom;

  res.json(papier);
});

// DELETE /api/papiers/:id - Supprimer un papier
app.delete('/api/papiers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = papiers.findIndex(p => p.id === id);

  if (index === -1) {
    return res.status(404).json({ error: 'Papier non trouvé' });
  }

  papiers.splice(index, 1);
  res.status(204).send();
});

// === DÉMARRAGE DU SERVEUR ===
const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`
  ================================================
  🚀 API Papier.net démarrée !
  ================================================

  URL: http://localhost:${PORT}

  Routes disponibles:
  - GET    /health         → Vérifier que l'API tourne
  - GET    /api/papiers    → Liste des papiers
  - POST   /api/papiers    → Créer un papier
  - PATCH  /api/papiers/1  → Modifier un papier
  - DELETE /api/papiers/1  → Supprimer un papier

  ================================================
  `);
});

// Export pour les tests
module.exports = app;
// Version 1.1
