# Project Compass (working title)

A local-first personal organization system inspired by the Bullet Journal method, with optional AI assistance.

## Approved architecture
- Mobile: Expo + React Native + TypeScript
- Browser extension: WXT + React + TypeScript (Chrome and Firefox)
- Core API: NestJS + TypeScript
- AI gateway: FastAPI + Python
- Data: PostgreSQL; local SQLite (mobile) and IndexedDB (extension)
- Auth/managed infrastructure: Supabase Auth + managed PostgreSQL
- Monorepo: pnpm workspaces + Turborepo

## Repository status
This is a starter scaffold, not a production-ready application. App directories contain minimal entry points and configuration placeholders. Generate the full Expo, WXT, NestJS and FastAPI applications in their respective directories before implementing product features.

## Prerequisites
- Node.js 22 LTS (or the version pinned by the team)
- pnpm 9+
- Python 3.12+
- Docker (for local PostgreSQL)
- Expo tooling / Android Studio / Xcode as needed

## Getting started
```bash
corepack enable
pnpm install
cp .env.example .env
docker compose -f infrastructure/docker/compose.yml up -d
pnpm lint
pnpm typecheck
pnpm test
```

The initial scripts are intentionally conservative. Add package-level scripts as each application is generated.

## Engineering rules
1. NestJS is the only service allowed to persist product-domain data.
2. The AI service returns validated proposals; it never writes to PostgreSQL.
3. Clients persist user actions locally first and sync through the API.
4. Every record is owned by a user; enforce ownership in service logic and database policies.
5. Never log journal content, access tokens, secrets, or raw AI prompts by default.
6. AI must be disableable, and users must be able to scope what context it can process.

## First implementation milestones
1. Generate application shells in `apps/mobile`, `apps/extension`, `services/api`, and `services/ai-service`.
2. Implement Supabase Auth integration and a `profiles` table linked to `auth.users(id)`.
3. Implement entries, tasks and tags with ownership checks and tests.
4. Add client outboxes and idempotent sync operations.
5. Add AI provider adapters and structured output validation.
