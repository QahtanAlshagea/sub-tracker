# skills-routing.md — Mandatory Skill Routing Table for the Sub Tracker Agent

> **Binding rule:** Before proposing a design, writing code, reviewing code, or answering an engineering question in this workspace, the agent MUST scan this table, load every skill whose trigger matches, and declare `SKILLS APPLIED: <list>` in its reply (see `codeguaid.md` §1 Step 2 and §8).
> **Multiplicity:** Most tasks match two to four skills. Loading only one when several match is a rule violation.
> **Precedence on conflict:** `codeguaid.md` > `GEMINI.md` > `clean-architecture` > domain-specific skill > general skill.
> **Skill root:** `.agents/skills/`

---

## 1. Always-on skills (loaded in every single session, no exception)

| Skill | Path | Why it is always loaded |
|---|---|---|
| `clean-architecture` | `.agents/skills/clean-architecture/` | Defines the layering and persistence isolation the whole codebase depends on. |
| `dart-run-static-analysis` | `.agents/skills/dart-run-static-analysis/` | Verification step 6 of the mandatory loop runs on every task. |
| `dart-add-unit-test` | `.agents/skills/dart-add-unit-test/` | No implementation is allowed without its test contract. |

---

## 2. Architecture and project structure

| Trigger (task contains…) | Skill(s) to load | Expected output |
|---|---|---|
| Creating folders, wiring layers, composition root, dependency injection | `clean-architecture`, `flutter-apply-architecture-best-practices` | Layer map + file paths + dependency-direction proof |
| Introducing or changing a repository interface or use case contract | `clean-architecture`, `dart-add-unit-test`, `dart-generate-test-mocks` | Abstract contract + mock + unit tests |
| Local persistence design (tables, DAOs, transactions, migrations) | `clean-architecture/local-persistence-clean-architecture.md`, `flutter-apply-architecture-best-practices` | Table/DAO/DataSource/Repository split in separate files |
| Navigation and routing between screens | `flutter-setup-declarative-routing`, `clean-architecture` | Route table isolated from widgets |
| Introducing a new package dependency | `dart-resolve-package-conflicts` | Version resolution + justification + license note |

---

## 3. Domain layer (Pure Dart)

| Trigger | Skill(s) | Notes |
|---|---|---|
| Writing entities, value objects, failures | `dart-use-primary-constructors`, `dart-write-documentation`, `dart-add-unit-test` | Zero Flutter imports; document every public API |
| Branching on cycle types, result types, failure types | `dart-use-pattern-matching` | Use exhaustive switch/sealed types instead of if-chains |
| Calculation engine (monthly equivalent, forecasts, rounding) | `dart-add-unit-test`, `dart-use-pattern-matching`, `dart-write-documentation` | Reference values must be hand-verified in the test table |
| Public API documentation with runnable examples | `dart-use-doc-examples` | Examples must compile |
| Any file-path handling in pure Dart helpers | `dart-use-path-package` | Never concatenate paths with `/` |

---

## 4. Data layer (SQLite / Drift)

| Trigger | Skill(s) | Notes |
|---|---|---|
| Creating or altering Drift tables and indexes | `clean-architecture/local-persistence-clean-architecture.md` | One table per file, no business logic |
| Writing DAOs, transactions, bulk operations | `clean-architecture/local-persistence-clean-architecture.md`, `dart-add-unit-test` | Bulk = one atomic transaction (`EC-40`) |
| Schema migration work | `clean-architecture/local-persistence-clean-architecture.md`, `dart-add-unit-test` | Migration test from every previous schema version |
| Backup export/import (JSON) | `flutter-implement-json-serialization`, `dart-use-path-package`, `dart-add-unit-test` | Serialization lives in `data/models/`, never in `domain/` |
| Runtime database errors, lock timeouts, corrupt file | `dart-fix-runtime-errors`, `clean-architecture` | Convert to domain `Failure`, never leak the exception |
| Mocking repositories or DAOs for tests | `dart-generate-test-mocks` | Generated mocks only |
| Native/FFI or asset-backed storage experiments | `dart-setup-ffi-assets`, `dart-use-ffigen` | Out of scope for this phase — require lead approval first |

---

## 5. Presentation layer (UI/UX)

| Trigger | Skill(s) | Notes |
|---|---|---|
| Any new screen, widget, card, form, or layout | `ui-ux-pro-max`, `ui-styling`, `design-system` | Load all three; tokens only, no magic values |
| Theme work, dark/light mode, color system, typography scale | `design-system`, `ui-styling`, `brand` | Contrast ≥ 4.5:1 |
| Responsive/adaptive layout, tablet, orientation change | `flutter-build-responsive-layout`, `ui-ux-pro-max` | Form state must survive rotation (`EC-22`) |
| Overflow, clipping, constraint or render errors | `flutter-fix-layout-issues` | Fix the constraint, do not wrap blindly in `Expanded` |
| Empty states, loading states, error states, micro-interactions | `ui-ux-pro-max`, `design-system` | Every screen needs all three states |
| Arabic/RTL text, localization keys, number and date formats | `flutter-setup-localization`, `ui-ux-pro-max` | No user-facing string inline in code |
| Previewing a widget in isolation while building | `flutter-add-widget-preview` | Preview is a dev aid, never shipped as app code |
| Icons, illustrations, banners, marketing visuals | `design`, `banner-design`, `brand` | Only when explicitly requested by the team |
| Presentation or demo slides for the course | `slides` | Documentation task, not app code |

---

## 6. Testing and quality assurance

| Trigger | Skill(s) | Notes |
|---|---|---|
| Any new or changed logic | `dart-add-unit-test` | Test contract before implementation |
| Needing test doubles for an interface | `dart-generate-test-mocks` | Regenerate after any contract change |
| Testing a screen, widget, or its three states | `flutter-add-widget-test` | Cover empty/loading/error |
| End-to-end flow across layers | `flutter-add-integration-test` | Also used for the < 100 ms performance assertions |
| Measuring or reporting coverage | `dart-collect-coverage` | Domain ≥ 85%, data ≥ 70% |
| Before any Pull Request | `dart-run-static-analysis`, `dart-collect-coverage` | `--fatal-infos`, zero warnings |
| Assertion style modernization | `dart-migrate-to-checks-package` | Only as an isolated `refactor:` task |
| Any runtime crash or exception report | `dart-fix-runtime-errors` | Reproduce with a failing test first, then fix |

---

## 7. Tooling, documentation and CLI

| Trigger | Skill(s) | Notes |
|---|---|---|
| Writing or updating dartdoc / public API docs | `dart-write-documentation`, `dart-use-doc-examples` | Public APIs must be documented |
| Building a helper CLI (migration script, data generator) | `dart-build-cli-app`, `dart-use-path-package` | Lives in `tool/`, never in `lib/` |
| Dependency version conflicts after `pub get` | `dart-resolve-package-conflicts` | Report the resolution reasoning in the PR |
| Network/HTTP work | `flutter-use-http-package` | **Blocked this phase** — offline-first; requires an approved scope change (`OS-02`) |

---

## 8. Routing decision procedure (execute in order, every task)

1. **Classify the task** into one or more of: architecture · domain · data · presentation · testing · tooling · documentation.
2. **Load section 1** (always-on skills) unconditionally.
3. **Load every matching row** from sections 2–7. If two rows match, load both skill sets.
4. **Read the actual skill files** — never rely on the skill's name or on memory of what it probably says.
5. **Declare** `SKILLS APPLIED: <list>` at the top of the reply.
6. **Apply the skill literally.** If a skill contradicts the user's request, follow the precedence order above and explain the conflict instead of silently choosing.
7. **On no match:** state `SKILLS APPLIED: none — rationale: <why>` and proceed only if `codeguaid.md` allows the task at all.
8. **After execution:** if the task revealed a recurring pattern with no skill covering it, propose a new skill file under `.agents/skills/` rather than repeating ad-hoc guidance.

---

## 8-bis. Required reading alongside the skills

Skills tell the agent *how* to write the code; the project documents tell it *what is allowed*. For every task the agent also opens the matching document: `docs/ARCHITECTURE.md` for structure and data-model questions, `docs/TEST_PLAN.md` for test design, `docs/RISK_REGISTER.md` for money, time, storage, permissions, backup and destructive actions, and `docs/KANBAN_AND_GIT_WORKFLOW.md` before opening any branch or pull request.

---

## 9. Quick lookup index

| If the task mentions… | Load |
|---|---|
| entity, use case, contract, failure | `clean-architecture`, `dart-add-unit-test`, `dart-use-primary-constructors` |
| Drift, table, DAO, migration, transaction | `local-persistence-clean-architecture`, `dart-add-unit-test` |
| screen, widget, card, theme, color, spacing | `ui-ux-pro-max`, `ui-styling`, `design-system` |
| overflow, layout error, responsive, tablet | `flutter-fix-layout-issues`, `flutter-build-responsive-layout` |
| test, coverage, mock, edge case | `dart-add-unit-test`, `dart-generate-test-mocks`, `flutter-add-widget-test`, `dart-collect-coverage` |
| JSON, backup, export, import | `flutter-implement-json-serialization`, `dart-use-path-package` |
| Arabic, RTL, translation, date format | `flutter-setup-localization` |
| route, navigation, deep link | `flutter-setup-declarative-routing` |
| crash, exception, null error | `dart-fix-runtime-errors` |
| analyze, lint, warning | `dart-run-static-analysis` |
| docs, dartdoc, example | `dart-write-documentation`, `dart-use-doc-examples` |
| slides, banner, brand, icon | `slides`, `banner-design`, `brand`, `design` |
