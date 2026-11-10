# Mobile app

Generate the Expo app here, keeping TypeScript enabled.

Suggested bootstrap from repository root:
```bash
pnpm dlx create-expo-app@latest apps/mobile --template
```

Choose a TypeScript-compatible Expo template, then add SQLite persistence and a network-aware sync worker. Do not store provider secrets in the mobile bundle.
