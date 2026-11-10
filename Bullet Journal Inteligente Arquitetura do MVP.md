# Bullet Journal Inteligente: Arquitetura do MVP

*Extensão de navegador + aplicativo mobile com captura de baixo esforço, sincronização offline-first e multi-dispositivo.*

> **Nota de confidencialidade:** este documento é de uso privado do projeto. Eu (Claude) não posso assinar nem aplicar um NDA juridicamente. Para proteção real, mantenha detalhes sensíveis fora do chat e use um NDA assinado com as pessoas para quem você for mostrar o projeto.

## Visão geral

O método Bullet Journal funciona por causa do **registro rápido** (tarefas, eventos, notas), da **migração** (revisar e mover itens não concluídos), das **coleções** e do **índice**. O atrito está no fato de ser manual, e por isso muita gente abandona. A oportunidade de produto é manter a filosofia e remover o esforço.

## Decisões do projeto

- **Stack:** React em tudo (extensão Chrome MV3 + React Native com Expo) e Supabase no backend.
- **Foco:** engenharia (sincronização, parsing, offline), com boa UX/UI.
- **Sincronização:** offline-first com sincronização em tempo real entre dispositivos.
- **Recursos de baixo esforço do MVP:** captura por voz, revisão assistida de migração e datas em linguagem natural.
- **Contas:** magic link por e-mail.

## Arquitetura

### Monorepo (pnpm + Turborepo)

- `packages/core`: TypeScript compartilhado com o modelo de dados, o parser de registro rápido, o parsing de datas e o motor de sincronização. Os dois clientes o importam, e é o coração da peça de portfólio.
- `apps/extension`: Chrome MV3 com Vite e React. Armazena dados no IndexedDB (Dexie).
- `apps/mobile`: Expo com React Native. Armazena dados com expo-sqlite.
- `supabase/`: migrations, políticas RLS e edge functions.

## Motor de sincronização

É aqui que vale concentrar o esforço de engenharia.

- **UUIDs gerados no cliente**, para criar registros offline sem ida ao servidor.
- **Escrita local-first**: a interface sempre lê e escreve no banco local. Cada mudança também entra em uma **outbox** de operações, reenviada até ser confirmada e idempotente.
- **Resolução de conflitos**: last-writer-wins por campo, usando **hybrid logical clocks** (HLC), para que a diferença de relógio entre dispositivos não corrompa os dados. Exclusões são lógicas (tombstones). Bullets são curtos, então um CRDT seria exagero, e essa escolha pode ser justificada no case study.
- **Tempo real**: o Supabase Realtime envia as mudanças de outros dispositivos para o armazenamento local. Ao reconectar, o cliente busca tudo o que é mais novo que seu último cursor.
- **Alternativa pragmática**: o PowerSync resolve boa parte disso. Um motor próprio demonstra mais profundidade, então a ideia é construí-lo e citar o PowerSync como trade-off considerado.

## Modelo de dados

**`bullets`**: id, user\_id, type (task/event/note), content, status (open/done/migrated/scheduled/dropped), log\_date, due\_at, collection\_id, migrated\_from, migration\_count, hlc, deleted\_at

**`collections`**: id, user\_id, name, hlc, deleted\_at

RLS para que cada usuário acesse apenas as próprias linhas.

## Recursos de baixo esforço

- **Datas em linguagem natural**: chrono-node, com suporte a vários idiomas. O parser transforma `o jantar sexta 20h` em um evento na data correta.
- **Captura por voz**: Web Speech API na extensão e um módulo de reconhecimento de fala no Expo. A transcrição passa pelo mesmo parser do texto digitado, então existe um único caminho de código.
- **Revisão assistida de migração**: uma fila focada de itens não concluídos com ações de um toque ou atalho de teclado: migrar, agendar, mover para uma coleção ou descartar. Itens migrados três ou mais vezes recebem o lembrete "ainda vale a pena?", que captura o espírito do método.

## Autenticação

Magic link por e-mail via Supabase. Na extensão, os redirecionamentos são problemáticos, então a sugestão é usar o **código OTP de 6 dígitos** do mesmo e-mail, que é mais simples e confiável. O app mobile pode usar o código ou um deep link.

## Marcos

1. `core`: tipos, parser e HLC, com testes unitários
2. Schema do Supabase, RLS e autenticação
3. Extensão: captura rápida e log diário, apenas local
4. Motor de sincronização: outbox, pull, realtime e testes de conflito
5. App mobile: log diário
6. Captura por voz e revisão de migração
7. Polimento de UX e case study

## Próximo passo

Começar pelo marco 1: criar o monorepo, o pacote `core` e a migration inicial do Supabase.
