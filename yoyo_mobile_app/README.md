# Restaurant & Café - Plateforme POS (Web / Mobile / Desktop)

Ce dépôt contient une base complète et prête à lancer pour une application de gestion Restaurant & Café avec un **seul code source**.

## Structure du projet

```
./
├─ backend/                # API REST Node.js (Express + PostgreSQL)
│  ├─ db/                  # Schéma SQL PostgreSQL
│  ├─ src/
│  │  ├─ config/           # Configuration .env + PostgreSQL
│  │  ├─ common/           # Types partagés (rôles, JWT)
│  │  ├─ modules/          # Auth, Users, Products, Orders
│  │  └─ server.ts         # Entrée API
│  ├─ .env.example
│  ├─ package.json
│  └─ tsconfig.json
├─ frontend/               # Ionic React (PWA + Capacitor)
│  ├─ src/
│  │  ├─ pages/            # Login, POS, Menu, Commandes, Paiement
│  │  ├─ services/         # API + IndexedDB offline
│  │  └─ stores/           # Auth store
│  ├─ .env.example
│  ├─ package.json
│  ├─ tsconfig.json
│  └─ vite.config.ts
├─ desktop/                # Electron (build desktop)
│  ├─ src/
│  │  └─ main.ts
│  ├─ package.json
│  └─ tsconfig.json
└─ package.json            # Scripts racine (backend/frontend/build)
```

## Démarrage rapide

1. **Backend**
   ```bash
   cd backend
   cp .env.example .env
   npm install
   npm run dev
   ```

2. **Frontend (Web/PWA)**
   ```bash
   cd frontend
   cp .env.example .env
   npm install
   npm run dev
   ```

3. **Desktop (Electron)**
   ```bash
   cd desktop
   npm install
   npm run build
   npm run dev
   ```

## Base de données

Le schéma PostgreSQL est disponible dans `backend/db/schema.sql`.

## Notes
- L'authentification est basée sur JWT.
- Les rôles pris en charge: `serveur`, `caissier`, `manager`.
- Le mode hors-ligne est géré via IndexedDB côté frontend.
