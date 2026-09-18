# GEMINI.md — Sub Tracker Project Directive

> Root-level operating context for the Gemini Coding Agent in Google Antigravity IDE.
> Read this file at the start of every session, then `.agents/rules/codeguaid.md`, then `.agents/rules/skills-routing.md`.

---

## 1. System context

**Sub Tracker** is an **offline-first** Flutter application for tracking subscriptions and recurring bills. All data is created, stored, computed and analysed **on the device**. There is no server, no account, no network call, and no internet permission in this phase.

| Attribute | Value |
|---|---|
| Framework | Flutter (Dart) |
| Persistence | SQLite via Drift, local only |
| Architecture | Clean Architecture — `presentation` / `domain` / `data` |
| Phase | Inception & Elaboration (documentation and contracts before code) |
| Team | قحطان الشاجع (lead/architect) · أواب النزيلي (domain) · مشعل حاجب (persistence) · محمد العيدروس (UI/UX) · محمد العواضي (QA) |
| Doc language | Arabic for `docs/`, English for code, configs and agent files |

**Source of truth, in order:**
1. `docs/SRS.md` — numbered requirements `FR-01…FR-15`, `NFR-01…NFR-08`
2. `docs/USER_STORIES.md` — `US-01…US-40` with Given/When/Then and a per-story edge-case list
3. `docs/ARCHITECTURE.md` — architectural decisions, data model, data flow, extension rules
4. `docs/TEST_PLAN.md` — test pyramid, coverage floors, quality gates
5. `docs/RISK_REGISTER.md` — end-to-end defensive precautions and project risks
6. `docs/KANBAN_AND_GIT_WORKFLOW.md` — task cards `C-01…C-18`, branching and review protocol
7. `.agents/rules/codeguaid.md` — binding agent rules
8. `.agents/rules/skills-routing.md` — which skill to load, when

No implementation exists without a trace to (1) and (2).

---

## 2. Layered architecture

```
┌─────────────────────── PRESENTATION ───────────────────────┐
│ Screens · Widgets · State · Formatters · Theme/Tokens      │
│ imports: domain only                                        │
└──────────────────────────┬─────────────────────────────────┘
                           │ calls UseCases
┌──────────────────────────▼─────────────────────────────────┐
│                DOMAIN — PURE DART, ZERO DEPENDENCIES        │
│ Entities · Value Objects · Failures                         │
│ Repository Interfaces (abstract) · UseCases                 │
└──────────────────────────▲─────────────────────────────────┘
                           │ implements interfaces
┌──────────────────────────┴─────────────────────────────────┐
│                          DATA                               │
│ Tables · DAOs · Models · LocalDataSources · RepositoryImpl  │
│ imports: domain + drift/sqlite                              │
└─────────────────────────────────────────────────────────────┘
```

**Non-negotiable:** dependencies point inward. `domain/` imports nothing from `flutter`, `drift`, `dart:io` or `dart:ui`.

---

## 3. Data flow pattern

```
User action
  → Widget event handler
  → State holder (presentation/state)
  → UseCase (domain)
  → Repository interface (domain, abstract)
  → RepositoryImpl (data)
  → LocalDataSource (data)
  → DAO (data)
  → Drift / SQLite
      ↓ result or low-level exception
  → DAO returns rows / throws
  → RepositoryImpl maps rows → entities, exceptions → Failure
  → UseCase returns Either<Failure, T>
  → State holder maps to view state (data / empty / loading / error)
  → Widget renders one of four states, never a blank screen
```

Every read path must render a designed empty state; every write path must be atomic and double-tap protected.

**Money rule:** amounts are stored as integer minor units, never as floating point. Amounts in two different currencies are never summed into one figure.

**Time rule:** dates are stored in UTC with a local calendar-day anchor, and recurrence is always computed from the original anchor day, never from the previous clamped occurrence.

---

## 4. Project structure

```
Sub Tracker/
├── GEMINI.md
├── AI_Log.md
├── README.md
├── docs/
│   ├── SRS.md
│   ├── USER_STORIES.md
│   ├── ARCHITECTURE.md
│   ├── TEST_PLAN.md
│   ├── RISK_REGISTER.md
│   ├── KANBAN_AND_GIT_WORKFLOW.md
│   └── TEAM_LEAD_GITHUB_GUIDE.md
├── .agents/
│   ├── mcp_config.json
│   ├── rules/{codeguaid.md, skills-routing.md}
│   └── skills/{clean-architecture, dart-*, flutter-*, ui-ux-pro-max, ui-styling, design-system, ...}
├── lib/
│   ├── core/{database, error, di, utils}
│   └── features/subscriptions/{domain, data, presentation}
├── test/
│   ├── unit/{domain, data}
│   ├── widget/
│   └── integration/
└── tool/
```

`test/` mirrors `lib/` path for path. A file in `lib/` without a mirrored test is incomplete work.

---

## 5. Tooling and AI operations

| Tool | Purpose |
|---|---|
| Google Antigravity IDE + Gemini Agent | Primary engineering assistant, bound by `codeguaid.md` |
| `.agents/skills/` | 40+ installed Dart/Flutter/UI skills — routed by `skills-routing.md` |
| `.agents/mcp_config.json` | Wires Dart/Flutter static analysis, tests and coverage into the agent loop |
| GitHub + GitHub Projects | Issues, Kanban board, Pull Requests, branch protection |
| GitHub Actions | format → analyze → test → coverage on every PR |

**Agent loop, short form:** ground in the requirement → load matching skills → plan → write the test contract → implement → verify (format/analyze/test) → self-audit → log in `AI_Log.md`.

---

## 6. Quality gates

| Gate | Threshold |
|---|---|
| Static analysis | `flutter analyze --fatal-infos` → zero issues |
| Formatting | `dart format --set-exit-if-changed .` → clean |
| Tests | 100% passing |
| Coverage | domain ≥ 85%, data ≥ 70% |
| Local operation latency | < 100 ms |
| Memory | < 50 MB typical, < 60 MB peak |
| Accessibility | contrast ≥ 4.5:1, touch ≥ 48×48, RTL, 200% text scale |
| Review | ≥ 1 approving review, no direct push to `main`/`develop` |

---

## 7. Extensibility guidelines (future phases)

The current design is deliberately shaped so that later work touches only the outermost layer.

**Adding cloud sync (post-Lab scope `OS-02`):**
1. Add `data/datasources/subscription_remote_data_source.dart`.
2. Extend `RepositoryImpl` (or add a sync-aware implementation) to reconcile local and remote.
3. Add conflict-resolution policy and sync metadata columns via a versioned migration.
4. **Do not touch** `domain/` or `presentation/`. If a change there becomes necessary, the abstraction was wrong — fix the abstraction, not the layer.

**Swapping the database engine:**
- Replace `data/tables/`, `data/daos/`, `data/datasources/`; keep `RepositoryImpl`'s public contract identical. Domain tests must pass unchanged — that is the acceptance criterion for the swap.

**Adding a new feature module:**
- Create `lib/features/<feature>/{domain,data,presentation}` with the same internal structure. Shared code goes to `lib/core/`, never cross-imported between feature folders.

**Adding a platform (web/desktop):**
- Presentation only. Domain and data contracts stay untouched; only the Drift backend factory changes.

---

## 8. Hard boundaries for this phase

Out of scope and to be refused if requested: direct bank payment gateways, card processing, cloud sync, user accounts, reading SMS/email for bill extraction, live currency conversion, multi-user admin panels, web/desktop builds.

Refer any request in this list back to `docs/SRS.md` §4.2 and require a written scope change approved by the team lead before acting.
