# GEMINI.md — Sub Tracker Project Directive & AI Agent Operational Manual

> **Root-Level Operating Context for AI Coding Agents & Engineers in Google Antigravity IDE & GitHub.**  
> **Mandatory Reading Order:** Read this file first, then `.agents/rules/codeguaid.md`, then `.agents/rules/skills-routing.md`.

---

## 1. System Context, Tech Stack & Project Status

### 1-1 What is Sub Tracker? (ماذا بنينا وماذا اشتغلنا)
**Sub Tracker (متتبع الالتزامات والدفعات الدورية)** is an **offline-first**, privacy-by-design Flutter mobile application designed for comprehensive tracking and accounting of recurring financial obligations (subscriptions, monthly utility bills, house rent, software licenses, recurring services, loan installments) with local SHA-256 PIN security, multi-currency accounting integrity, on-device notifications, and interactive financial analytics.

All data is created, stored, calculated, and analyzed **exclusively on the local device**. There is no cloud backend, no third-party tracking, no server, and **zero internet permissions** (`android.permission.INTERNET` is strictly prohibited and removed from the manifest).

### 1-2 Technologies & Packages Used (ماذا استخدمنا)
| Component / Layer | Technology / Package | Engineering Purpose |
|---|---|---|
| **Framework & Language** | Flutter 3.22+ / Dart 3.4+ | Multi-platform declarative UI engine and type-safe language |
| **Persistence Engine** | SQLite via `drift: ^2.18.0` + `sqlite3_flutter_libs` | Type-safe, reactive, ACID-compliant local relational database with WAL mode |
| **Visual Analytics** | `fl_chart: ^1.2.0` | High-performance interactive pie and bar charts for expense distribution |
| **Notifications** | `flutter_local_notifications: ^17.2.1` + `timezone: ^0.9.4` | On-device scheduled reminders with boot recovery and exact alarm support |
| **Local Cryptography** | `crypto: ^3.0.3` | Local SHA-256 cryptographic hashing with salt for PIN lock security |
| **Localization & Dates** | `flutter_localizations` + `intl: ^0.19.0` | Comprehensive Arabic RTL localization, dates, and number formatting |
| **Architecture** | Clean Architecture (Domain / Data / Presentation) | Decoupled, 100% testable, pure business logic |

### 1-3 Project Health & Current Implementation Status (في أي مرحلة وصلنا)
| Attribute | Current Value | Verification Output |
|---|---|---|
| **Current Stage** | **Production Ready (Release V2.0.0)** | Final release with complete feature set |
| **Source Files** | **152 Dart source files** cleanly isolated | Single Responsibility Principle (SRP) enforced |
| **Test Suite Status** | **525 automated tests passing (100% pass rate)** | `flutter test` → 0 failures across unit and widget tests |
| **Static Analysis** | **0 issues found (Clean 100%)** | `flutter analyze --fatal-infos` → No issues found |
| **Code Formatting** | Compliant across 100% of files | `dart format --set-exit-if-changed .` → 0 diffs |
| **Edge Cases Covered** | **151 edge cases (`[EC-01-1]` to `[EC-42-3]`)** | Tested in code with requirement traceability |
| **Application Icon** | 3D Luxury Octane-rendered Adaptive Icon | Sized across all Android `mipmap` densities |
| **Packaging Status** | Android Release APK tested | `build/app/outputs/flutter-apk/app-release.apk` |

### 1-4 Academic Accreditation & Governance (جامعة إب)
- **Institution:** الجمهورية اليمنية — جامعة إب (University of Ibb) — كلية علوم الحاسوب وتكنولوجيا المعلومات — قسم هندسة البرمجيات.
- **Course:** مقرر هندسة البرمجيات النظري والتطبيقي (المعمل البرمجي المتقدم).
- **Academic Supervisor:** **م. ساهر الهمداني (Eng. Saher Al-Hamdani)**.
- **Team Roles & Responsibility Matrix (`.github/CODEOWNERS`):**
  1. **قحطان الشاجع (@QahtanAlshagea):** Team Lead & Software Architect — System Architecture, Governance, AI Agent Rules, Kanban Management, and Master Reviewer (`docs/`, `.agents/`, `GEMINI.md`, PR Review).
  2. **محمد العيدروس (@Eng-Mohammed-Al-aidrous):** Domain Layer Engineer — Entities, Value Objects, Business Invariants, Abstract Contracts, and UseCases (`lib/features/*/domain/`).
  3. **أواب النزيلي (@AWNO-1):** Presentation Layer Engineer — Design Tokens, UI/UX, Four ViewStates, Responsive Views, and Arabic Localization (`lib/features/*/presentation/`, `lib/l10n/`).
  4. **محمد العواضي (@dragongold2022-design):** Persistence & Data Layer Engineer — Drift/SQLite Tables, DAOs, Atomic Transactions, and Backup JSON Importer/Exporter (`lib/features/*/data/`).
  5. **مشعل حاجب (@mshalhajep):** QA & Security Engineer — Comprehensive Test Suite (525 tests), 151 Edge Cases Matrix, and Offline SHA-256 PIN Security (`test/`, Security Services).

---

## 2. Architectural Hierarchy & Inward Dependency Rules

The project strictly adheres to **Clean Architecture** with three decoupled layers and unidirectional inward dependencies:

```
┌─────────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER (العرض)                   │
│   Screens · Widgets · ViewState (Data/Loading/Empty/Error)  │
│   Controllers (MVVM) · Arabic Pluralization · fl_chart      │
│   Imports: Domain Layer ONLY                                │
└──────────────────────────────┬──────────────────────────────┘
                               │ calls UseCases
┌──────────────────────────────▼──────────────────────────────┐
│           DOMAIN LAYER (النطاق — PURE DART 100%)            │
│   Entities · Value Objects (Money, Pin) · Failures          │
│   Repository Interfaces (Abstract Contracts) · UseCases     │
│   Imports: ZERO external packages (NO Flutter, NO Drift)    │
└──────────────────────────────▲──────────────────────────────┘
                               │ implements interfaces
┌──────────────────────────────┴──────────────────────────────┐
│                  DATA LAYER (البيانات والتخزين)              │
│   Drift Tables · DAOs · LocalDataSources · SQLite Engine    │
│   Models · Repository Implementations · Atomic Transactions │
│   Imports: Domain + Drift/SQLite                            │
└─────────────────────────────────────────────────────────────┘
```

### Inviolable Layering Rules:
1. **Domain Purity (Zero Tolerance):** The `domain/` directory must NEVER import `package:flutter/*`, `package:drift/*`, `dart:io`, `dart:ui`, or any platform/database library. It is 100% pure Dart.
2. **Inward Dependencies:** Dependencies point strictly inward. High-level business rules never know about UI widgets or database tables.
3. **Repository Pattern:** Domain defines abstract repository interfaces (`SubscriptionRepository`, `CategoryRepository`, `PaymentRepository`, `SecurityRepository`); the Data layer implements them; UseCases depend only on abstractions.
4. **Single Responsibility (SOLID - SRP):** One entity per file, one use case per file, one DAO per file, one table per file. Never bundle multiple concerns into a single file.

---

## 3. Core Business & Invariant Rules

Any AI Agent or human contributor modifying or extending the system MUST enforce these rules:

1. **The Strict Money Rule:**
   - Monetary amounts are ALWAYS stored and computed as integer minor units (e.g., cents: $15.99 = `1599`).
   - Floating-point types (`double`) are strictly forbidden for financial arithmetic to avoid rounding inaccuracies (IEEE 754 floating-point error).
   - **Never sum differing currencies:** Amounts in two different currencies (e.g., YER and USD) must NEVER be summed into a single total figure. Separate summaries must be maintained for each currency.

2. **The Calendar Anchor Rule (Recurrence Invariant):**
   - Recurrence calculation is always anchored to the original calendar start day (`anchorDay`).
   - If an obligation is on the 31st and falls in February, it clamps to February 28 (or 29 in leap years), but in March it automatically snaps back to the 31st. Never compute from a previously clamped occurrence.

3. **The Four ViewStates Rule:**
   - Every screen in the Presentation layer must handle and render 4 explicit states:
     1. `DataState`: Normal rendering with loaded information.
     2. `LoadingState`: Responsive skeleton loaders or non-blocking indicators (`AppLoadingView`).
     3. `EmptyState`: Meaningful illustrated empty state with a call-to-action button (`AppEmptyView`).
     4. `ErrorState`: Clear Arabic error explanation with a retry button (`AppErrorView`).

4. **Security & Offline Storage Rule:**
   - PINs are hashed using SHA-256 with a local salt before verification or storage. Raw digits are never logged or stored.
   - After 5 consecutive failed PIN attempts, enforce a 30-second lockout with a live countdown timer.

---

## 4. Instructions for Incoming AI Coding Agents

When an AI Agent starts working on this repository, it MUST adhere to the following workflow:

### Step 1: Ground Yourself in Requirements & Context
- Review existing documentation: `docs/SRS.md` (`FR-01` to `FR-21`), `docs/USER_STORIES.md` (`US-01` to `US-42`), and `docs/RISK_REGISTER.md`.
- Match requested features against established edge cases (`[EC-XX-Y]`).
- Do NOT improvise or invent features outside the approved domain scope.

### Step 2: Route & Declare Required Skills
- Consult `.agents/rules/skills-routing.md` and load the matching skills from `.agents/skills/`.
- Declare `SKILLS APPLIED: <skills>` explicitly in your reasoning.

### Step 3: Write Test Contracts First (Test-First Gate)
- **Do not write implementation code until the test contract is established.**
- Create/update unit tests under `test/unit/` or widget tests under `test/widget/` mirroring `lib/`.
- Name tests after the traceability requirement (e.g., `test('US-05 / EC-01: month-end 31st clamps to 28th in February', ...)`).

### Step 4: Implement Incrementally & Concurrently
- Write the minimum clean implementation satisfying the test contract.
- Keep files under 400 lines and methods under 50 lines.
- Preserve domain purity (pure Dart in `domain/`).

### Step 5: Verify & Quality Gate Enforcement
Execute the following verification commands and ensure 100% clean output:
```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```
If any test fails or analyzer warning occurs, fix it immediately. Never commit red output.

### Step 6: Log & Document
- Update `AI_Log.md` with: date, student name, tool used, purpose, accepted proposals, rejected proposals, and human reviewer notes.
- Update relevant architecture or user story documents if schema or behavior evolved.

### Step 7: Git & GitHub Workflow
- Work in an isolated feature branch (`feature/c-XX-...`) branching off `develop`.
- **CRITICAL RULE:** Never commit heavy binary artifacts into Git (e.g., `*.pdf`, `*.apk`, `*.jar`, temporary scratch folders). These must remain excluded in `.gitignore`.
- Push to GitHub origin, create a Pull Request targeting `develop`, request review from the responsible `@CODEOWNER`, and merge into `main` after verification passes.

---

## 5. Directory Structure & Key Files Map

```
sub-tracker/
├── .agents/
│   ├── rules/
│   │   ├── codeguaid.md         # Mandatory operating rules, 7-step loop, SOLID principles (<12k chars)
│   │   └── skills-routing.md    # Dynamic agent skills routing table (<12k chars)
│   └── skills/                  # Installed Dart & Flutter agent skills
├── docs/                        # Complete Software Engineering Academic Documentation (Arabic)
│   ├── SRS.md                   # Software Requirements Specification (FR-01..21, NFR-01..08)
│   ├── ARCHITECTURE.md          # Technical Architecture, SQLite/Drift Data Model, Minor Units
│   ├── USER_STORIES.md          # 42 User Stories & 151 Edge Cases Matrix [EC-01-1..EC-42-3]
│   ├── TEST_PLAN.md             # QA & Test Strategy, Coverage thresholds, Testing pyramid
│   ├── RISK_REGISTER.md         # 10 Defensive Lifecycle Risk mitigations
│   ├── KANBAN_AND_GIT_WORKFLOW.md # 18 Kanban Task Cards, GitHub Projects/Trello, Gitflow
│   ├── TEAM_EXECUTION_GUIDE.md  # Step-by-step Execution manual for each team member
│   └── TEAM_LEAD_GITHUB_GUIDE.md# Branch protection, CODEOWNERS, CI workflows guide
├── lib/
│   ├── core/                    # Shared infrastructure (database, themes, notifications, utilities)
│   │   ├── database/            # Drift AppDatabase, schema migrations, SQLite engine
│   │   ├── services/            # NotificationService, scheduled alarms
│   │   ├── theme/               # Design tokens (AppColors, AppTypography, AppSpacing, ThemeExtension)
│   │   └── utils/               # BackupFileManager, CurrencyIconResolver
│   ├── features/subscriptions/  # Subscriptions feature module
│   │   ├── domain/              # 100% PURE DART: Entities, Value Objects, Failures, Contracts, UseCases
│   │   ├── data/                # Drift Tables, DAOs, Models, Local DataSources, Repository Impls
│   │   └── presentation/        # Screens, Custom Widgets, MVVM Controllers, Arabic Formatters
│   ├── l10n/                    # Localization ARB files (Arabic default)
│   └── main.dart                # Composition root, dependency injection, Offline PIN gate
├── test/
│   ├── unit/                    # Fast unit tests for Domain logic, UseCases, DAOs, Formatters
│   └── widget/                  # Component and Screen widget tests for the 4 ViewStates
├── AI_Log.md                    # Transparent log of all AI prompts, proposals, and decisions
├── GEMINI.md                    # Root directive and operational manual (This file)
└── README.md                    # Public GitHub presentation with badges, architecture, screenshots
```

---

## 6. Prohibited Actions (Stop Conditions)

An AI Agent must immediately refuse and stop if requested to:
1. Add internet permissions (`android.permission.INTERNET`) or any remote analytics/tracking SDK.
2. Store plaintext PINs, credit card numbers, or bank credentials.
3. Import Flutter or Drift packages into the `domain/` directory.
4. Merge or push directly to `main` without PR review.
5. Skip test contracts or commit code with failing tests or analyzer warnings.
6. Commit large binary artifacts (such as APKs or PDF reports) into the Git commit tree.
