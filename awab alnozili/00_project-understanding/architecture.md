# المعمارية الفنية للمشروع (Architecture)

## 1. نمط المعمارية: Clean Architecture

يعتمد مشروع **Sub Tracker** معمارية الطبقات النظيفة الصارمة (**Clean Architecture**) مع فصل كامل ومستقل للمسؤوليات وفق مبادئ **SOLID**.

```text
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION                         │
│  Screens · Widgets · State Holders · Formatters · Tokens    │
│  (Imports: Domain Only)                                     │
└──────────────────────────────┬──────────────────────────────┘
                               │ calls UseCases
┌──────────────────────────────▼──────────────────────────────┐
│                    DOMAIN (Pure Dart)                       │
│  Entities · Value Objects · Failures · Repository Contracts │
│  UseCases · Business Validators · Calculation Engines       │
│  (Zero Dependencies on Flutter / Storage / IO)              │
└──────────────────────────────▲──────────────────────────────┘
                               │ implements Repository Contracts
┌──────────────────────────────┴──────────────────────────────┐
│                            DATA                             │
│  Drift Tables · DAOs · Local DataSources · Data Models      │
│  Repository Implementations · Exception-to-Failure Mappers   │
│  (Imports: Domain + Drift / SQLite)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. قواعد التبعية الصارمة (Dependency Rules)

1. **التبعية تتجه للداخل دائماً:**
   - طبقة العرض (`presentation`) تستورد فقط طبقة الدومين (`domain`).
   - طبقة البيانات (`data`) تستورد فقط طبقة الدومين (`domain`) ومحرك التخزين (`drift/sqlite`).
   - طبقة الدومين (`domain`) **نقية 100% بلغة Dart**: محظور استيراد `flutter`, `drift`, `sqflite`, `dart:io`, `dart:ui` أو أي مكتبة طرف ثالث.
2. **فحص النقاء التلقائي في CI:**
   يقوم خط الأنابيب (`.github/workflows/ci.yml`) بفحص نقاء الدومين عبر تعبير نمطي (Regex):
   ```bash
   grep -rnE "import .*(flutter|drift|sqflite|dart:io|dart:ui)" lib/**/domain/
   ```
   وأي استيراد مخالف يؤدي لكسر البناء فوراً ومنع الدمج.
3. **عزل ملفات التخزين والواجهة:**
   تعديل أي شاشة أو عنصر واجهة لا يمس الدومين أو قاعدة البيانات مطلقاً. وتعديل أي جدول أو استعلام لا يمس الدومين أو شاشات الواجهة.

---

## 3. تدفق البيانات (Data Flow Lifecycle)

```text
[User Action / Tap]
       │
       ▼
[Widget Event Handler] (presentation/widgets)
       │
       ▼
[State Holder] (presentation/state)
       │
       ▼ calls
[UseCase] (domain/usecases)
       │
       ▼ calls abstract contract
[Repository Interface] (domain/repositories)
       │
       ▼ implemented by
[RepositoryImpl] (data/repositories)
       │
       ▼ calls
[LocalDataSource / DAO] (data/datasources, data/daos)
       │
       ▼ executes query
[Drift / SQLite Engine] (core/database)
       │
       ├───────────────────────────────────┬───────────────────────────────────┐
       ▼ (On Success)                      ▼ (On Low-level Exception)
[Returns Database Rows]             [Throws SqliteException / RemoteException]
       │                                   │
       ▼                                   ▼
[Data Models map to Entities]       [Exception mapped to Domain Failure]
       │                                   │
       └─────────────────┬─────────────────┘
                         ▼
        [Returns Result<T>: Success or Error]
                         │
                         ▼
        [UseCase returns Result<T> to State]
                         │
                         ▼
        [State maps to ViewState (Data, Empty, Loading, Error)]
                         │
                         ▼
        [Widget renders designed state without ever crashing or showing a blank screen]
```

---

## 4. تطبيق مبادئ SOLID الخمسة في المشروع

| المبدأ | التطبيق في Sub Tracker |
|---|---|
| **S — Single Responsibility (المسؤولية الواحدة)** | كل صنف وملف له مسؤولية واحدة ومبرر واحد للتغيير: الكيانات لحفظ القواعد، الـ UseCase لتنسيق عملية عمل واحدة، الـ DAO للاستعلام، الشاشة للعرض فقط. |
| **O — Open/Closed (المفتوح/المغلق)** | النظام مفتوح للتوسع عبر الواجهات المجردة (`domain/repositories/`)، ومغلق أمام التعديل. يمكن استبدال محرك التخزين أو إضافة اختبارات وهمية دون تعديل الدومين أو الواجهات. |
| **L — Liskov Substitution (إحلال ليسكوف)** | أي تنفيذ للـ Repository في طبقة البيانات يحل محل العقد المجرد بدقة تامة دون إطلاق استثناءات غير متوقعة. |
| **I — Interface Segregation (فصل الواجهات)** | واجهات المستودعات مركزة وصغيرة، ولا يُجبر أي كائن على الاعتماد على دوال لا يحتاجها. |
| **D — Dependency Inversion (عكس التبعية)** | الطبقات العليا (UseCases) تعتمد على تجريدات (`domain/repositories/`) وليس على كائنات ملموسة، ويتم ربط التبعيات فقط في جذر التركيب (`lib/core/di/`). |

---

## 5. إدارة الأخطاء والنتائج الوظيفية (Result & Failure Contract)

- يتم التعامل مع النتائج بأسلوب وظيفي آمن عبر الصنف المختوم `Result<T>` (`Success<T>` أو `Error<T>`) دون إطلاق استثناءات هاربة (`throw`).
- جميع الاستثناءات منخفضة المستوى (`SqliteException`, `FileSystemException`, إلخ) تُلتقط في طبقة البيانات وتُحوّل عند حدود المستودع إلى كائنات فشل معمارية واضحة ترث من `Failure`:
  - `DatabaseFailure`
  - `NotFoundFailure`
  - `ValidationFailure`
  - `StorageFullFailure`
  - `CorruptedDataFailure`
  - `SubscriptionDomainFailure` (وفروعها التفصيلية: كشف التكرار، تجاوز الحدود، خطأ العملة، إلخ).

---

## 6. القواعد الهندسية الحاكمة للمال والوقت

### أ. القاعدة المالية الصارمة (Minor Units Rule):
- **يُمنع منعاً باتاً استخدام الأعداد العشرية العائمة (`double` أو `float`)** لتخزين المبالغ المالية لتجنب أخطاء التقريب الحسابي (IEEE 754).
- تُخزن جميع المبالغ كأعداد صحيحة 64-بت (`int` في Dart و `INTEGER` في SQLite) تمثل **الوحدات الصغرى للعملة** (مثال: $9.99 يُخزن 999 سنتاً).
- يُمنع جمع مبالغ من عملتين مختلفتين في رقم واحد إطلاقاً.

### ب. قاعدة التقويم والزمن (Time & Anchor Day Rule):
- تُخزن التواريخ بالتوقيت العالمي الموحد `UTC` مع حفظ **اليوم الأصلي المثبت للدورة** (`original_anchor_day` بين 1 و31).
- يتم احتساب الاستحقاقات القادمة دائماً بالرجوع إلى اليوم الأصلي وليس لليوم المشذب السابق، لمنع الانزياح التراكمي للشهور القصيرة (مثال: اشتراك 31 يناير -> 28 فبراير -> 31 مارس وليس 28 مارس).
- يتم احتساب التكرارات المتأخرة رياضياً بتعقيد $O(1)$ دون حلقات تكرار مهددة للأداء.
