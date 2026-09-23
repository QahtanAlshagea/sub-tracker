# skills-routing.md — Skill Routing Table for Sub Tracker Agent

> **Binding rule:** Before proposing a design, writing code, or reviewing in this workspace, the agent MUST scan this table, load all matching skills, and declare `SKILLS APPLIED: <list>` in its reply (`codeguaid.md` §1 Step 2).
> **Precedence:** `codeguaid.md` > `GEMINI.md` > `clean-architecture` > domain skill > general skill.
> **Skill root:** `.agents/skills/`

---

## 1. Always-on Skills (Every Session)
| Skill | Path | Purpose |
|---|---|---|
| `clean-architecture` | `.agents/skills/clean-architecture/` | Inward dependency & persistence isolation |
| `dart-run-static-analysis` | `.agents/skills/dart-run-static-analysis/` | Zero-tolerance static analysis on every step |
| `dart-add-unit-test` | `.agents/skills/dart-add-unit-test/` | Enforce test contracts before implementation |

---

## 2. Architecture & Structure
| Trigger | Skill(s) | Expected Output |
|---|---|---|
| Wiring layers, DI, composition root | `clean-architecture`, `flutter-apply-architecture-best-practices` | Layer map + dependency direction proof |
| Repository interface or use case contract | `clean-architecture`, `dart-add-unit-test`, `dart-generate-test-mocks` | Abstract contract + mock + unit tests |
| Local persistence design (tables, DAOs, transactions) | `clean-architecture/local-persistence-clean-architecture.md`, `flutter-apply-architecture-best-practices` | Table/DAO/DataSource/Repository file split |
| Navigation & routing | `flutter-setup-declarative-routing`, `clean-architecture` | Declarative route table isolated from widgets |
| Adding package dependency | `dart-resolve-package-conflicts` | Version resolution + justification |

---

## 3. Domain Layer (Pure Dart)
| Trigger | Skill(s) | Notes |
|---|---|---|
| Entities, value objects, failures | `dart-use-primary-constructors`, `dart-write-documentation`, `dart-add-unit-test` | Zero Flutter imports; document public APIs |
| Branching on cycles/failures | `dart-use-pattern-matching` | Use exhaustive switch/sealed types |
| Calculation engine (monthly equiv, rounding) | `dart-add-unit-test`, `dart-use-pattern-matching`, `dart-write-documentation` | Hand-verified reference values in test tables |
| Public API docs with examples | `dart-use-doc-examples` | Runnable, compiling examples |
| Path handling in pure Dart helpers | `dart-use-path-package` | Never concatenate with `/` |

---

## 4. Data Layer (SQLite / Drift)
| Trigger | Skill(s) | Notes |
|---|---|---|
| Drift tables & indexes | `clean-architecture/local-persistence-clean-architecture.md` | One table per file, no business logic |
| DAOs, transactions, bulk operations | `clean-architecture/local-persistence-clean-architecture.md`, `dart-add-unit-test` | Bulk operations in atomic transactions |
| Schema migration | `clean-architecture/local-persistence-clean-architecture.md`, `dart-add-unit-test` | Migration tests from previous versions |
| Backup export/import (JSON) | `flutter-implement-json-serialization`, `dart-use-path-package`, `dart-add-unit-test` | Serialization in `data/models/` only |
| DB runtime errors, lock timeouts | `dart-fix-runtime-errors`, `clean-architecture` | Convert to Domain `Failure` |
| Mocking repos/DAOs for tests | `dart-generate-test-mocks` | Generated mocks via Mockito only |

---

## 5. Presentation Layer (UI/UX)
| Trigger | Skill(s) | Notes |
|---|---|---|
| Design tokens, themes (light/dark) | `ui-ux-pro-max`, `design-system`, `ui-styling` | Tokens under `lib/core/theme/` (no magic values) |
| Screens, 4 ViewStates | `ui-ux-pro-max`, `flutter-apply-architecture-best-practices`, `flutter-add-widget-test` | Empty, Loading, Error, Data states required |
| Responsive layout, RTL, text scale | `flutter-build-responsive-layout`, `ui-ux-pro-max` | Support 200% text scale without overflow |
| Layout overflow, RenderFlex errors | `flutter-fix-layout-issues` | Fix unbounded constraints |
| Localization, Arabic plurals | `flutter-setup-localization`, `recurring-commitments-expert` | 6 Arabic plural forms in ARB files |
| Visual charts (`fl_chart`) | `recurring-commitments-expert`, `flutter-add-widget-test` | Interactive pie chart + touch feedback |
| PIN lock & security screens | `recurring-commitments-expert`, `flutter-add-widget-test` | Offline SHA-256 + 30s lockout |

---

## 6. Testing & Quality Gates
| Trigger | Skill(s) | Notes |
|---|---|---|
| Unit test writing | `dart-add-unit-test` | Happy path, failure paths, story edge cases |
| Widget test writing | `flutter-add-widget-test` | Verify 4 ViewStates + accessibility |
| Integration tests / user flows | `flutter-add-integration-test` | End-to-end user journeys |
| Checking coverage | `dart-collect-coverage` | Domain ≥ 85%, Data ≥ 70% |
| Linting & static analysis | `dart-run-static-analysis` | 0 warnings (`--fatal-infos`) |
| Modern assertions | `dart-migrate-to-checks-package` | Use package:checks where applicable |

---

## 7. Execution Loop Rule Check
When opening a task:
1. Scan triggers above to select matching skills.
2. Read the `SKILL.md` for each selected skill before coding.
3. Declare `SKILLS APPLIED: <list>` in your reply.
4. Enforce test-first contracts before writing any production code.
