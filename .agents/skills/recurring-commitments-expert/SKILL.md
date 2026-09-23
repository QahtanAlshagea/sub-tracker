---
name: recurring-commitments-expert
description: Expert guidelines for offline recurring payments and obligations tracking in Sub Tracker. Covers offline PIN security, price history audit trails, interactive fl_chart components, and authentic Arabic grammatical pluralization.
scope: lib/**, test/**
---

# SKILL — Recurring Commitments & Payments Expert

## 1. When to Load This Skill
Load this skill whenever working on:
- Offline PIN authentication, cryptographic hashing, and brute-force lockout defenses.
- Atomic financial audit trails and subscription price change history (`price_history`).
- Interactive financial charts (`fl_chart` Pie and Bar widgets).
- 4 View States enforcement (Data, Loading, Empty, Error with Retry) across screens.
- Multi-currency display and calculations (never combine amounts in different currencies).
- Authentic Arabic grammatical pluralization and currency localization.

---

## 2. Architectural & Defensive Guidelines

### 2.1 Offline Local PIN Security Gate
- **No Cloud/Network:** Hashing and verification happen 100% locally on the device using SHA-256.
- **Value Object Invariant:** `PinCode` strictly accepts exactly 4 numeric digits (`^\d{4}$`).
- **Brute-Force Lockout Defense:** Any UI keypad or lock screen must enforce a temporary 30-second lockout after 5 consecutive incorrect attempts.
- **Startup Protection Gate:** When PIN is enabled, `main.dart` must route to `PinLockScreen` before revealing user financial records in `HomeScreen`.

### 2.2 Atomic Financial Audit Trail (Price History)
- Whenever a subscription or recurring obligation amount changes, the modification MUST be wrapped in a database transaction.
- An immutable `PriceHistoryEntry` is inserted containing `oldAmount`, `newAmount`, `changedAt` (UTC), and `currencyCode`.
- Amounts must always be stored and calculated as integer minor units (never floating point).

### 2.3 Interactive Visual Analytics (`fl_chart`)
- Wrap charts in `AspectRatio` or explicit containers to prevent layout unbounded constraint errors.
- Support tactile touch interaction (e.g., enlarging the tapped slice in `PieChart` and displaying percentage + minor unit cost).
- Ensure color tokens respect semantic theme palettes (`billColor`, `rentColor`, `overdueColor`).

### 2.4 Authentic Arabic Pluralization & Localization
Always use `ArabicPluralFormatter` rather than naive string concatenation:
- `0`: "لا توجد دفعات"
- `1`: "دفعة واحدة"
- `2`: "دفعتان"
- `3..10`: "$count دفعات"
- `11+`: "$count دفعة"

### 2.5 Multi-Currency Principle (BR-07)
Never aggregate sums of different currencies into a single aggregate metric. If the user tracks commitments in multiple currencies (e.g., USD, YER, SAR), render separated metrics and charts per currency selection.
