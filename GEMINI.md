# GEMINI.md — Sub Tracker Project Directive & AI Agent Operational Manual

> **Root-Level Operating Context for AI Coding Agents & Engineers in Google Antigravity IDE & GitHub.**  
> **Mandatory Reading Order:** Read this file first, then `.agents/rules/codeguaid.md`, then `.agents/rules/skills-routing.md`.

---

## 1. System Context & Project Status

**Sub Tracker** is an **offline-first**, privacy-by-design Flutter mobile application for tracking and managing recurring financial obligations (subscriptions, utility bills, rent, services, installments) with local SHA-256 PIN security, multi-currency accounting integrity, and interactive financial analytics.

All data is created, stored, calculated, and analyzed **exclusively on the local device**. There is no server, no external account, no network call, and **zero internet permissions** (`android.permission.INTERNET` is strictly prohibited).

### Project Health & Current Implementation Status:
| Attribute | Current Value |
|---|---|
| Framework & Language | Flutter 3.22+ / Dart 3.4+ |
| Persistence Engine | SQLite via Drift (Type-safe, reactive, ACID local persistence) |
| Architecture Pattern | Clean Architecture — `domain` (Pure Dart) / `data` (Persistence) / `presentation` (UI) |
| Current Phase | **Production Ready & Final Expansion (Release V2.0.0)** |
| Source Files | 152 Dart source files cleanly isolated |
| Test Suite Status | **525+ automated tests passing (100% pass rate)** |
| Static Analysis | **`flutter analyze --fatal-infos` → 0 issues found (Clean)** |
| Code Formatting | `dart format` compliant across all files |
| Packaging Status | Android Release APK successfully built and tested (`متتبع_الاشتراكات.apk`) |
| Academic Institution | **جامعة إب (University of Ibb) — كلية علوم الحاسوب وتكنولوجيا المعلومات — قسم هندسة البرمجيات** |
| Academic Supervisor | **م. ساهر الهمداني (Eng. Saher Al-Hamdani)** |
| Academic Team & Roles | • **قحطان الشاجع (@QahtanAlshagea):** Team Lead & Software Architect (Docs, .agents, Core Governance, Master Reviewer)<br>• **محمد العيدروس (@Eng-Mohammed-Al-aidrous):** Domain Layer, Business Invariants, Contracts & UseCases<br>• **أواب النزيلي (@AWNO-1):** Presentation Layer, UI/UX, Responsive Views & Localization<br>• **محمد العواضي (@dragongold2022-design):** Persistence, Data Layer, Drift/SQLite Tables & DAOs<br>• **مشعل حاجب (@mshalhajep):** QA, Quality Assurance, Test Suite & 151 Edge Cases |
| Documentation Language | Arabic for `docs/` and reports; English for source code, identifiers, and agent configs |

---

## 2. Architectural Hierarchy & Inward Dependency Rules

```
┌─────────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER (العرض)                   │
│   Screens · Widgets · ViewState (Data/Loading/Empty/Error)  │
│   Formatters · Arabic Pluralization · fl_chart Visuals      │
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
3. **Repository Pattern:** Domain defines abstract repository interfaces; the Data layer implements them; UseCases depend only on abstractions.
4. **Isolated File Responsibilities (SOLID - SRP):** One entity per file, one use case per file, one DAO per file, one table per file. Never bundle multiple concerns into a single file.

---

## 3. Core Business & Invariant Rules

Any AI Agent or human contributor modifying or extending the system MUST enforce these rules:

1. **The Strict Money Rule:**
   - Monetary amounts are ALWAYS stored and computed as integer minor units (e.g., cents: $15.99 = `1599`).
   - Floating-point types (`double`) are strictly forbidden for financial arithmetic to avoid rounding inaccuracies.
   - **Never sum differing currencies:** Amounts in two different currencies (e.g., YER and USD) must NEVER be summed into a single total figure. Separate summaries must be maintained for each currency.

2. **The Calendar Anchor Rule (Recurrence Invariant):**
   - Recurrence calculation is always anchored to the original calendar start day (`anchorDay`).
   - If an obligation is on the 31st and falls in February, it clamps to February 28 (or 29 in leap years), but in March it automatically snaps back to the 31st. Never compute from a previously clamped occurrence.

3. **The Four ViewStates Rule:**
   - Every screen in the Presentation layer must handle and render 4 explicit states:
     1. `DataState`: Normal rendering with loaded information.
     2. `LoadingState`: Responsive skeleton loaders or non-blocking indicators.
     3. `EmptyState`: Meaningful illustrated empty state with a call-to-action button (never a blank screen).
     4. `ErrorState`: Clear Arabic error explanation with a retry button.

4. **Security & Offline Storage Rule:**
   - PINs are hashed using SHA-256 with a local salt before verification or storage. Raw digits are never logged or stored.
   - After 5 consecutive failed PIN attempts, enforce a 30-second lockout with a live countdown timer.

---

## 4. Instructions for Incoming AI Coding Agents

When an AI Agent starts working on this repository, it MUST adhere to the following workflow:

### Step 1: Ground Yourself in the Requirements
- Locate the functional requirement in `docs/SRS.md` (`FR-01` to `FR-21`) or non-functional requirement (`NFR-01` to `NFR-08`).
- Locate the user story in `docs/USER_STORIES.md` (`US-01` to `US-42`) and its associated edge cases (`[EC-XX-Y]`).
- Do NOT improvise or invent requirements outside the approved scope.

### Step 2: Route & Activate Required Skills
- Consult `.agents/rules/skills-routing.md` and load the matching skills from `.agents/skills/`.
- Declare `SKILLS APPLIED: <skills>` explicitly in your reasoning.

### Step 3: Write Test Contracts First (Test-First Gate)
- **Do not write implementation code until the test contract is established.**
- Create/update unit tests under `test/unit/` or widget tests under `test/widget/` mirroring `lib/`.
- Name tests after the traceability requirement (e.g., `test('US-05 / EC-01: month-end 31st clamps to 28th in February', ...)`).

### Step 4: Implement Incrementally & Concurrently
- Write the minimum clean implementation satisfying the test contract.
- Keep files under 400 lines and methods under 50 lines.

### Step 5: Verify & Quality Gate Enforcement
Execute the following verification commands and ensure 100% clean output:
```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```
If any test fails or analyzer warning occurs, fix it immediately. Never commit red output.

### Step 6: Log & Document
- Update `AI_Log.md` with: task card ID, summary of changes, test contract executed, and verification output.
- Update relevant architecture or user story documents if schema or behavior evolved.

### Step 7: Git & PR Workflow
- Always work in an isolated feature branch (`feature/c-XX-...`).
- Do NOT push directly to `main` or `develop`.
- Stage only source code, tests, and documentation. Never commit large binary artifacts (such as APKs or multi-megabyte PDFs) into the Git commit tree.
- Create a Pull Request targeting `develop` and request review from the responsible `@CODEOWNER`.

---

## 5. Extensibility Guide: How to Add Future Features

The system is architected for seamless extension without modifying core domain rules:

1. **Adding Cloud Synchronization:**
   - Create `data/datasources/cloud_sync_remote_data_source.dart`.
   - Implement a sync-aware repository `SyncAwareSubscriptionRepositoryImpl` implementing `SubscriptionRepository`.
   - Add conflict resolution policies without touching `domain/entities/` or `presentation/`.

2. **Adding Biometric Authentication:**
   - Define abstract `BiometricAuthService` in `domain/repositories/`.
   - Implement `LocalBiometricsAdapter` in `data/datasources/` using platform hardware channels.
   - Add `AuthenticateWithBiometricsUseCase` and call it from `PinLockScreen`.

3. **Adding On-Device OCR Bill Scanner:**
   - Create `OnDeviceBillDocumentScanner` in `data/datasources/` wrapping local machine learning vision models.
   - Add `ExtractSubscriptionFromReceiptUseCase` in `domain/usecases/`.
   - Hook into `AddEditScreen` to pre-fill form fields.

4. **Adding New Localizations:**
   - Add `lib/l10n/app_<lang>.arb`.
   - Define pluralization rules and run `flutter gen-l10n`.

---

## 6. Prohibited Actions (Stop Conditions)

An AI Agent must immediately refuse and stop if requested to:
1. Add internet permissions (`android.permission.INTERNET`) or any remote analytics/tracking SDK.
2. Store plaintext PINs, credit card numbers, or bank credentials.
3. Import Flutter or Drift packages into the `domain/` directory.
4. Merge or push directly to `main` without PR review.
5. Skip test contracts or commit code with failing tests.
