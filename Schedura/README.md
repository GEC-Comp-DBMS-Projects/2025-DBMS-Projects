
# Schedura

Schedura is a booking and scheduling platform implemented as a small monorepo. It contains an Express-based backend (integrations and payments) and a mobile-first Expo / React Native frontend. The backend uses Supabase (Postgres) as the primary data store and integrates with Google Calendar and Razorpay.

## Table of contents

- Project overview
- Architecture
- Quick start
	- Prerequisites
	- Environment variables
	- Run backend
	- Run frontend (Expo)
- Database / Supabase notes
- API highlights
- Development notes
- Contributing
- License

## Project overview

This repository contains two main pieces:

- `backend/` — Express server implementing Google Calendar integration (OAuth flow, event creation) and Razorpay payment flows (order creation, verification, optional transfers). It uses `@supabase/supabase-js` to persist integration and payment metadata.
- `frontend/` — Expo-managed React Native app that provides the user interface for bookings, spaces, and payments.

There are additional helper folders for Supabase configuration and small serverless functions under `backend/supabase/` and `supabase/`.

## Architecture

- Frontend: Expo / React Native with `expo-router`. Uses Supabase client for auth and to talk to the backend APIs.
- Backend: Express (`backend/server.js`) that handles OAuth callbacks, server-side API calls to Google & Razorpay, and updates Supabase tables.
- Data: Supabase (Postgres) for storing integration records, payments, users, bookings, etc.

## Quick start

These steps get the app running locally for development.

### Prerequisites

- Node.js (>= 18 recommended)
- npm or Yarn
- Expo CLI for mobile development (optional): `npm install -g expo-cli` or use `npx expo`
- Android SDK / emulator or an iOS simulator (macOS) for testing mobile builds


### Run backend

1. Install dependencies

```bash
cd backend
npm install
```

2. Start the server

```bash
node server.js
```

The backend listens on port 5000 by default and logs: `✅ Backend running on http://localhost:5000`.

If you run into ESM-related errors (for example, `Unexpected token import`), add `"type": "module"` to `backend/package.json` or run Node with an appropriate loader so the `import` syntax is supported.

### Run frontend (Expo)

1. Install dependencies and start Expo

```bash
cd frontend
npm install
npm run start   # or `npm run android` / `npm run ios` / `npm run web`
```

2. Open the Expo dev tools or scan the QR code to run on a device or emulator.

The `frontend/package.json` already contains common scripts: `start`, `android`, `ios`, `web`, and `lint`.


## Development notes

- Keep secret keys out of the frontend. The frontend should only use public keys intended for client use.
- If you need hot reload for the backend, add a `dev` script using `nodemon` in `backend/package.json`:

```json
"scripts": {
	"start": "node server.js",
	"dev": "nodemon server.js"
}
```

- If you add or change DB columns, update Supabase migrations and verify the backend queries.

## Contributing

1. Fork the repository and create a feature branch.
2. Make changes and include tests where relevant.
3. Open a pull request with a clear description of the change.

Please follow the existing frontend lint rules and formatting conventions. There is a `frontend/scripts/reset-project.js` script that may help with local resets.

## License

See `LICENSE.md` at the repository root for license terms.

