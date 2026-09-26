# المعمارية الفنية وقواعد التصميم (Architecture & SOLID)
## المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

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

| المبدأ | التطبيق في نطاق عمل محمد العيدروس (الدومين) |
|---|---|
| **S — Single Responsibility (المسؤولية الواحدة)** | كل صنف وملف له مسؤولية واحدة ومبرر واحد للتغيير: كل UseCase ينفذ عملية واحدة (Add, Edit, Cancel, etc.)، والكيانات تحفظ سلامة القواعد فقط، والمحاسب المالي يحسب فقط دون أي أثر جانبي. |
| **O — Open/Closed (المفتوح/المغلق)** | عقود الدومين (`SubscriptionRepository` و `CategoryRepository`) واجهات مجردة مفتوحة لأي تطبيق (Drift محلي أو Mock لاختبارات الوحدة أو مستقبلاً مزامنة سحابية) ومغلقة أمام التعديل. |
| **L — Liskov Substitution (إحلال ليسكوف)** | الفئات الوهمية المولدة `MockSubscriptionRepository` تحل تماماً وبدقة محل العقد الأصلي في اختبارات الـ UseCases. |
| **I — Interface Segregation (فصل الواجهات)** | الواجهات مركزة وصغيرة ولا تجبر أي طرف على اعتماد توابع لا يحتاجها. |
| **D — Dependency Inversion (عكس التبعية)** | حالات الاستخدام لا تعرف شيئاً عن Drift أو SQLite أو الجداول؛ تعتمد حصراً على واجهات الدومين المجردة التي يتم حقنها عند التركيب. |

---

## 5. القواعد الهندسية الحاكمة للمال والوقت

### أ. القاعدة المالية الصارمة (Minor Units Rule):
- **يُمنع منعاً باتاً استخدام الأعداد العشرية العائمة (`double` أو `float`)** لتخزين المبالغ المالية لتجنب أخطاء التقريب الحسابي (IEEE 754).
- تُخزن جميع المبالغ كأعداد صحيحة 64-بت (`int` في Dart و `INTEGER` في SQLite) تمثل **الوحدات الصغرى للعملة** (مثال: $9.99 يُخزن 999 سنتاً).
- يُمنع جمع مبالغ من عملتين مختلفتين في رقم واحد إطلاقاً.

### ب. قاعدة التقويم والزمن (Time & Anchor Day Rule):
- تُخزن التواريخ بالتوقيت العالمي الموحد `UTC` مع حفظ **اليوم الأصلي المثبت للدورة** (`original_anchor_day` بين 1 و31).
- يتم احتساب الاستحقاقات القادمة دائماً بالرجوع إلى اليوم الأصلي وليس لليوم المشذب السابق، لمنع الانزياح التراكمي للشهور القصيرة (مثال: اشتراك 31 يناير -> 28 فبراير -> 31 مارس وليس 28 مارس).
- يتم احتساب التكرارات المتأخرة رياضياً بتعقيد $O(1)$ دون حلقات تكرار مهددة للأداء.
