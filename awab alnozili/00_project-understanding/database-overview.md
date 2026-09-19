# نموذج قاعدة البيانات والتخزين المحلي (Database Overview)

يعتمد تطبيق **Sub Tracker** على نموذج تخزين محلي كامل عبر محرك **SQLite** باستخدام مكتبة **Drift** في بيئة Flutter/Dart، ومصمم وفق مبدأ العزل الكامل في طبقة البيانات (`data/`) دون تسريب أي تفاصيل لطبقة الدومين (`domain/`).

---

## 1. مخطط الجداول والعلاقات (Schema & Relationships)

```text
┌─────────────────────────────────┐
│           categories            │
├─────────────────────────────────┤
│ PK  id : TEXT                   │◀──────────────┐
│     name : TEXT [UNIQUE]        │               │
│     color_value : INTEGER       │               │
│     icon_code : TEXT?           │               │ 1:N (ON DELETE RESTRICT)
│     is_system : INTEGER         │               │
│     created_at : INTEGER        │               │
└─────────────────────────────────┘               │
                                                  │
┌─────────────────────────────────┐               │
│          subscriptions          │               │
├─────────────────────────────────┤               │
│ PK  id : TEXT                   │               │
│     name : TEXT                 │               │
│     price_minor_units : INTEGER │               │
│     currency_code : TEXT        │               │
│     cycle_type : TEXT           │               │
│     custom_cycle_days : INT?    │               │
│     start_date : INTEGER        │               │
│     next_due_date : INTEGER     │               │
│     original_anchor_day : INT   │               │
│ FK  category_id : TEXT          │───────────────┘
│     status : TEXT               │
│     is_trial : INTEGER          │
│     notes : TEXT?               │
│     renewal_url : TEXT?         │
│     payment_method_desc : TEXT? │
│     reminder_enabled : INTEGER  │
│     reminder_lead_days : INT    │
│     reminder_time_hour : INT    │
│     reminder_time_minute : INT  │
│     created_at : INTEGER        │
│     updated_at : INTEGER        │
│     deleted_at : INTEGER?       │
│     archived_at : INTEGER?      │
└────────────────┬────────────────┘
                 │
                 │ 1:N (ON DELETE CASCADE)
                 ▼
┌─────────────────────────────────┐
│          price_history          │
├─────────────────────────────────┤
│ PK  id : TEXT                   │
│ FK  subscription_id : TEXT      │
│     old_price_minor_units : INT │
│     new_price_minor_units : INT │
│     currency_code : TEXT        │
│     changed_at : INTEGER        │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│            settings             │ (Singleton Table)
├─────────────────────────────────┤
│ PK  id : TEXT ('app_settings')  │
│     theme_mode : TEXT           │
│     default_currency : TEXT     │
│     default_reminder_days : INT │
│     default_reminder_hour : INT │
│     default_reminder_minute: INT│
│     default_sort_order : TEXT   │
│     last_backup_at : INTEGER?   │
│     schema_version : INTEGER    │
│     updated_at : INTEGER        │
└─────────────────────────────────┘
```

---

## 2. تفصيل الجداول والحقول والقيود

### 2-1 جدول الفئات (`categories`)
- **المفتاح الأساسي (PK):** `id` (نص UUID v4).
- **القيود:** `name` فريد ومطهر (`NOT NULL UNIQUE`).
- **الحقول الخاصة:** `is_system` (راية 0 أو 1 لتمييز فئة "غير مصنف" المحمية من الحذف والتعديل).

### 2-2 جدول الاشتراكات (`subscriptions`)
- **المفتاح الأساسي (PK):** `id` (نص UUID v4).
- **المفتاح الأجنبي (FK):** `category_id` مرتبط بـ `categories(id)` مع قيد `ON DELETE RESTRICT` لمنع حذف فئة مرتبطة باشتراكات نشطة قبل إعادة تعيينها.
- **الحقول المالية:** `price_minor_units` (عدد صحيح $\ge 0$) و `currency_code` (ISO 4217 بثلاثة أحرف).
- **حقول التقويم:** `original_anchor_day` (عدد صحيح من 1 إلى 31) لحفظ يوم الشهر الأصلي، و `next_due_date` لحفظ الاستحقاق الحالي المعتمد.
- **الفهارس (Indexes):**
  - فهرس على `next_due_date` لتسريع استعلامات الصفحة الرئيسية والترتيب الزمني.
  - فهرس على `status` لتسريع استعلامات الفلترة (النشطة، المؤرشفة، المحذوفة).
  - فهرس على `category_id` لتحسين سرعة الربط (JOINs).

### 2-3 جدول سجل الأسعار (`price_history`)
- **المفتاح الأساسي (PK):** `id` (نص UUID v4).
- **المفتاح الأجنبي (FK):** `subscription_id` مرتبط بـ `subscriptions(id)` مع قيد `ON DELETE CASCADE` (يُحذف السجل آلياً عند الحذف النهائي للاشتراك لمنع السجلات اليتيمة).
- **الغرض:** توثيق كل تغيير في سعر الاشتراك مع طابعه الزمني، واستخدامه في توليد الرسوم البيانية ورصد تضخم الكلفة.

### 2-4 جدول الإعدادات العامة (`settings`)
- جدول أحادي السجل (Singleton)، مفتاحه الأساسي ثابت دائماً `'app_settings'`.
- يخزن السمة، العملة الافتراضية، إعدادات التنبيه الافتراضية، ورقم إصدار المخطط الداخلي.

---

## 3. القواعد والسياسات الهندسية للبيانات

### أ. سياسة الوحدات الصغرى (Minor Units Policy):
- تُحظر حقول `REAL` و `FLOAT` منعاً باتاً لحماية البيانات من أخطاء IEEE 754.
- العملات ثنائية المنازل (USD, SAR, YER, EUR) تُضرب في 100 وتُخزن كأعداد صحيحة.
- العملات معدومة المنازل (JPY, KRW) تُخزن كما هي.
- العملات ثلاثية المنازل (KWD, BHD) تُضرب في 1000.

### ب. المعاملات الذرية (ACID Transactions):
- جميع العمليات المتعددة (مثل: إضافة اشتراك مع تنبيه، تعديل سعر مع إضافة قيد في سجل الأسعار، حذف فئة مع إعادة تعيين اشتراكاتها، العمليات الجماعية، الاستيراد الشامل) تُغلف داخل **معاملة ذرية واحدة (Transaction)**، إما أن تنجح بالكامل أو تُلغى بالكامل دون ترك بيانات تالفة أو ناقصة.

### ج. حوكمة ترقية المخطط (Schema Migration Governance):
- إصدار المخطط الحالي هو الإصدار 1 وموثق الترقية للإصدار 2.
- جميع الترقيات غير هادمة للبيانات، ولا يُحذف عمود أو يُبدل نوعه دون سكربت ترحيل صريح ومختبر يضمن عدم فقدان أي سجل.
