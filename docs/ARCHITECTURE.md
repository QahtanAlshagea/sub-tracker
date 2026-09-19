# وثيقة المعمارية الفنية ونموذج البيانات
## نظام «Sub Tracker»

**إصدار الوثيقة:** 1.0 &nbsp;|&nbsp; **الوثيقة الأم:** وثيقة مواصفات المتطلبات البرمجية

**إعداد:** قحطان الشاجع، أواب النزيلي، مشعل حاجب، محمد العيدروس، محمد العواضي

**إشراف:** م. ساهر الهمداني

---

# 1. القرارات المعمارية الحاكمة

تُسجَّل القرارات الكبرى هنا بسببها لا بنصّها فقط، حتى يعرف من يأتي لاحقاً لماذا اتُّخذ القرار قبل أن يفكر في نقضه.

**القرار الأول: معمارية الطبقات النظيفة بثلاث طبقات.** السبب أن منطق الأعمال في هذا النظام أثقل من واجهته: قواعد التقويم وتحويل الدوريات وحساب التوقعات منطق محض يجب أن يكون قابلاً للاختبار دون جهاز ولا قاعدة بيانات. وعزله في طبقة نقية يجعل اختباره في أجزاء من الثانية بدل دقائق.

**القرار الثاني: العمل المحلي أولاً دون خادم.** السبب أن البيانات المالية الشخصية أخطر ما يُرفع إلى الشبكة، وأن انعدام الخادم يُسقط فئة كاملة من المخاطر ومن التكاليف ومن التعقيد. والثمن هو غياب المزامنة، وقد قُبل هذا الثمن صراحة في حدود النطاق.

**القرار الثالث: SQLite عبر Drift لا تخزين مفاتيح وقيم.** السبب أن النظام يحتاج استعلامات مركّبة وفرزاً وتصفية وربطاً بين جداول ومعاملات ذرّية، وكلها لا يوفرها تخزين المفاتيح والقيم إلا بكتابة قاعدة بيانات بدائية يدوياً.

**القرار الرابع: عكس التبعية عبر واجهات مجردة.** السبب أن كل التزام بمكتبة تخزين داخل منطق الأعمال يعني أن تغييرها لاحقاً يمسّ كل شيء. والواجهة المجردة تجعل الكلفة محصورة في طبقة واحدة.

**القرار الخامس: تمثيل الفشل بكائنات لا باستثناءات.** السبب أن الاستثناء يهرب من التوقيع فلا يجبر أحداً على التعامل معه، بينما نوع النتيجة يجبر المستدعي على معالجة مسار الفشل عند الترجمة لا عند التشغيل.

**القرار السادس: تخزين التواريخ بالتوقيت العالمي مع يوم تقويمي مرجعي.** السبب أن التوقيت الصيفي وتغيّر المناطق الزمنية يزيحان اليوم إذا خُزّن محلياً، وأن الاعتماد على التوقيت العالمي وحده يفقد معنى «اليوم» الذي يهم المستخدم.

---

# 2. الطبقات ومسؤولياتها

## 2-1 طبقة الدومين

قلب النظام، وهي شيفرة Dart نقية لا تستورد إطار العرض ولا محرك التخزين ولا وحدات الإدخال والإخراج. تضم **الكيانات** التي تمثل مفاهيم النظام، و**كائنات القيمة** التي تحمي ثوابتها بنفسها فلا يمكن إنشاء مبلغ سالب أصلاً، و**واجهات المستودعات** المجردة التي تصف ما يُطلب من التخزين دون أن تصف كيف يُنفَّذ، و**حالات الاستخدام** التي تمثل كل فعل يقوم به النظام، و**أنواع الإخفاق** التي تمثل كل ما قد يسوء.

## 2-2 طبقة البيانات

تنفّذ ما وصفته الطبقة الداخلية، وتحتكر وحدها معرفة قاعدة البيانات. وتنقسم إلى **تعريفات الجداول** التي تصف البنية ولا تحوي منطقاً، و**كائنات الوصول** التي تنفّذ الاستعلامات والمعاملات، و**النماذج** التي تحوّل بين صفوف القاعدة وكيانات الدومين وتتولى التمثيل النصي للنسخ الاحتياطي، و**مصادر البيانات** التي تجمع عدة كائنات وصول خلف واجهة مقصدية، و**تنفيذ المستودعات** الذي يحوّل النتائج إلى كيانات والاستثناءات إلى إخفاقات.

## 2-3 طبقة العرض

تعرض الحالة وتستقبل الأحداث ولا تعرف شيئاً عن التخزين. وتنقسم إلى **الشاشات** و**المكونات القابلة لإعادة الاستعمال** و**حائزي الحالة** الذين يستدعون حالات الاستخدام ويحوّلون نتائجها إلى حالة عرض، و**المنسّقات** التي تحوّل القيم إلى نصوص بحسب لغة الجهاز.

## 2-4 قاعدة اتجاه التبعية

تتجه التبعية نحو الداخل دائماً. فطبقة العرض تعرف الدومين ولا تعرف البيانات، وطبقة البيانات تعرف الدومين ولا تعرف العرض، والدومين لا يعرف أياً منهما. ويُربط الجميع في نقطة واحدة هي جذر التركيب، وهي الموضع الوحيد في النظام الذي يعرف الطبقات الثلاث معاً.

---

# 3. نموذج البيانات وحوكمة التخزين المحلي (SQLite & Drift)

يعتمد تطبيق **Sub Tracker** على نموذج تخزين محلي كامل (Offline-First Local Persistence) باستخدام محرك **SQLite** عبر مكتبة **Drift** في بيئة Flutter/Dart، مع الالتزام التام بعزل الطبقات وفق المعمارية النظيفة (Clean Architecture)؛ بحيث تُعرَّف الجداول والفهارس والـ DAOs ومصادر البيانات داخل طبقة البيانات (`data/`) ومجلد النواة المشتركة للمحرك (`core/database/`) دون أي تسريب لتفاصيل التخزين أو مكتبات Drift إلى طبقة الدومين (`domain/`).

---

## 3-1 سياسة العملات وتخزين المبالغ المالية بالوحدات الصغرى (Minor Units Policy)

### 3-1-1 العلة الهندسية
تستخدم لغات البرمجة الحديثة (بما فيها Dart) معيار **IEEE 754** لتمثيل الأعداد العشرية العائمة (`double`). هذا التمثيل يعاني بطبيعته من أخطاء عدم الدقة الحسابية (Floating-Point Rounding Errors) مثل `0.1 + 0.2 = 0.30000000000000004`. وفي الأنظمة المالية وإدارة الاشتراكات، يؤدي تراكم هذه الكسور على مدى مئات العمليات والتحويلات إلى فروقات حسابية مشوهة للتقارير وملخصات الإنفاق.

### 3-1-2 القاعدة الإلزامية في قاعدة البيانات
- **تُمنع الحقول العائمة منعاً باتاً:** يُحظر استخدام أعمدة `REAL` أو `FLOAT` في أي جدول مالي.
- **التخزين بوحدات صغرى صحيحة:** تُخزَّن جميع المبالغ في صورة أعداد صحيحة 64-بت (`INTEGER` في SQLite يقابلها `int` في Dart)، تمثل **الوحدة الصغرى للعملة** (Minor Currency Unit):
  - **العملات ثنائية المنازل (2 Decimals):** مثل الدولار الأمريكي (USD)، الريال السعودي (SAR)، الريال اليمني (YER)، واليورو (EUR).
    $$\text{Amount Minor Units} = \text{Amount Major Units} \times 100$$
    *مثال:* اشتراك بقيمة $\$9.99$ يُخزَّن في العمود كعدد صحيح `999`. ومبلغ $150.00$ ر.س يُخزَّن `15000`.
  - **العملات معدومة المنازل (0 Decimals):** مثل الين الياباني (JPY) والوون الكوري (KRW).
    $$\text{Amount Minor Units} = \text{Amount Major Units} \times 1$$
    *مثال:* $¥1000$ تُخزَّن `1000`.
  - **العملات ثلاثية المنازل (3 Decimals):** مثل الدينار الكويتي (KWD) والدينار البحريني (BHD).
    $$\text{Amount Minor Units} = \text{Amount Major Units} \times 1000$$
    *مثال:* $1.250$ د.ك يُخزَّن `1250`.

### 3-1-3 رموز العملات والتحويل إلى كائنات الدومين
- يُخزَّن رمز العملة في عمود `currency_code` كنص ثلاثي الأحرف مطابق لمعيار **ISO 4217** (مثل `"USD"`, `"YER"`, `"SAR"`, `"EUR"`).
- في طبقة الدومين، يُحوَّل الزوج (`price_minor_units`, `currency_code`) إلى كائن القيمة النقي `Money`، الذي يحوي العمليات الحسابية ويمنع الجمع بين عملتين مختلفتين، بينما تتولى طبقة العرض (`presentation/formatters`) تحويل القيمة الصغرى إلى النص التنسيقي المناسب لواجهة المستخدم بحسب لغة الجهاز وتنسيقات الأرقام المحلية.

---

## 3-2 مواصفات الجداول وقاموس البيانات (Data Dictionary)

يتكون المخطط المعتمد للتطبيق من أربعة جداول رئيسية موزعة وفق مبدأ المسؤولية الواحدة (SRP):

### 3-2-1 جدول الفئات (`categories`)
يُدير تصنيفات الاشتراكات والخدمات (مثل: ترفيه، عمل، تعليم، خدمات سحابية)، ويحتوي التصنيف النظامي الأساسي غير القابل للحذف.

| اسم الحقل | نوع SQLite | نوع Dart / Drift | القيود (Constraints) | الوصف الهندسي والوظيفي |
|---|---|---|---|---|
| `id` | `TEXT` | `String` | `PRIMARY KEY` | معرّف فريد بصيغة UUID v4 مُولَّد من التطبيق |
| `name` | `TEXT` | `String` | `NOT NULL UNIQUE` | اسم الفئة الفريد بعد التطبيع وتجريد الفراغات (1-24 حرفاً) |
| `color_value` | `INTEGER` | `int` | `NOT NULL` | القيمة العددية للون بصيغة ARGB 32-bit (مثال: `0xFF4F46E5`) |
| `icon_code` | `TEXT` | `String?` | `NULL` | معرّف الأيقونة أو اسم الرمز المعتمد في نظام التصميم |
| `is_system` | `INTEGER` | `bool` | `NOT NULL DEFAULT 0` | راية تميز الفئة النظامية «غير مصنّف» المحمية من التعديل والحذف (`1 = true, 0 = false`) |
| `created_at` | `INTEGER` | `DateTime` | `NOT NULL` | طابع زمني دقيق لإنشاء الفئة (مخزّن بمللي ثانية UTC أو ISO 8601) |

---

### 3-2-2 جدول الاشتراكات (`subscriptions`)
الجدول المركزي لإدارة كافة الالتزامات والاشتراكات الدورية وحالاتها وإعدادات تجديدها وتنبيهاتها.

| اسم الحقل | نوع SQLite | نوع Dart / Drift | القيود (Constraints) | الوصف الهندسي والوظيفي |
|---|---|---|---|---|
| `id` | `TEXT` | `String` | `PRIMARY KEY` | معرّف فريد بصيغة UUID v4 |
| `name` | `TEXT` | `String` | `NOT NULL` | اسم الاشتراك أو الخدمة المطبَّع (1-60 حرفاً) |
| `price_minor_units` | `INTEGER` | `int` | `NOT NULL CHECK(price_minor_units >= 0)` | المبلغ بالوحدة الصغرى للعملة (قيمة موجبة أو صفر للتجارب) |
| `currency_code` | `TEXT` | `String` | `NOT NULL` | رمز العملة وفق ISO 4217 بثلاثة أحرف كبيرة (مثل `"USD"`) |
| `cycle_type` | `TEXT` | `String` | `NOT NULL` | دورية التجديد كقيمة نصية من تعداد (`monthly`, `yearly`, `weekly`, `custom`) |
| `custom_cycle_days`| `INTEGER` | `int?` | `NULL CHECK(custom_cycle_days IS NULL OR custom_cycle_days BETWEEN 1 AND 3650)` | عدد أيام الدورية المخصصة (إلزامي إذا كان نوع الدورية `custom`) |
| `start_date` | `INTEGER` | `DateTime` | `NOT NULL` | تاريخ بداية أول دورة اشتراك بتوقيت UTC |
| `next_due_date` | `INTEGER` | `DateTime` | `NOT NULL` | تاريخ الاستحقاق القادم المحسوب بتوقيت UTC (مفهرس) |
| `original_anchor_day`| `INTEGER`| `int` | `NOT NULL CHECK(original_anchor_day BETWEEN 1 AND 31)` | اليوم الأصلي المثبت للدورة لحساب الشهور القصيرة والسنة الكبيسة |
| `category_id` | `TEXT` | `String` | `NOT NULL REFERENCES categories(id) ON DELETE RESTRICT` | مفتاح أجنبي يربط الاشتراك بفئته مع منع حذف الفئة المرتبطة |
| `status` | `TEXT` | `String` | `NOT NULL DEFAULT 'active'` | حالة الاشتراك (`active`, `archived`, `in_trash`) (مفهرس) |
| `is_trial` | `INTEGER` | `bool` | `NOT NULL DEFAULT 0` | راية تفيد ما إذا كان الاشتراك فترة تجريبية مجانية |
| `notes` | `TEXT` | `String?` | `NULL` | ملاحظات اختيارية يدوية (بحد أقصى 500 حرف) |
| `renewal_url` | `TEXT` | `String?` | `NULL` | رابط ويب صالح لصفحة إدارة الاشتراك وإلغائه |
| `payment_method_desc`| `TEXT` | `String?` | `NULL` | وصف وسيلة الدفع (مثل: «بطاقة فيزا 4242»، بحد أقصى 50 حرفاً) |
| `reminder_enabled` | `INTEGER` | `bool` | `NOT NULL DEFAULT 1` | تفعيل التنبيهات المحلية لهذا الاشتراك |
| `reminder_lead_days` | `INTEGER`| `int` | `NOT NULL DEFAULT 1 CHECK(reminder_lead_days BETWEEN 0 AND 30)` | مهلة الإشعار قبل الاستحقاق بعدد الأيام |
| `reminder_time_hour` | `INTEGER`| `int` | `NOT NULL DEFAULT 9 CHECK(reminder_time_hour BETWEEN 0 AND 23)` | ساعة التنبيه (0 إلى 23) |
| `reminder_time_minute`| `INTEGER`| `int` | `NOT NULL DEFAULT 0 CHECK(reminder_time_minute BETWEEN 0 AND 59)` | دقيقة التنبيه (0 إلى 59) |
| `created_at` | `INTEGER` | `DateTime` | `NOT NULL` | وقت إنشاء السجل بتوقيت UTC |
| `updated_at` | `INTEGER` | `DateTime` | `NOT NULL` | وقت آخر تحديث للسجل بتوقيت UTC |
| `deleted_at` | `INTEGER` | `DateTime?`| `NULL` | وقت النقل إلى سلة المحذوفات بتوقيت UTC |
| `archived_at` | `INTEGER` | `DateTime?`| `NULL` | وقت الأرشفة بتوقيت UTC |

---

### 3-2-3 جدول سجل تغير الأسعار (`price_history`)
يُوثق تاريخ تعديلات أسعار الاشتراكات عبر الزمن لتوليد الرسوم البيانية ورصد التضخم المالي.

| اسم الحقل | نوع SQLite | نوع Dart / Drift | القيود (Constraints) | الوصف الهندسي والوظيفي |
|---|---|---|---|---|
| `id` | `TEXT` | `String` | `PRIMARY KEY` | معرّف فريد بصيغة UUID v4 |
| `subscription_id`| `TEXT` | `String` | `NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE` | مفتاح أجنبي مرتبط بالاشتراك يُحذف تلقائياً مع حذف الاشتراك النهائي |
| `old_price_minor_units`| `INTEGER`| `int` | `NOT NULL CHECK(old_price_minor_units >= 0)` | المبلغ السابق بالوحدة الصغرى للعملة |
| `new_price_minor_units`| `INTEGER`| `int` | `NOT NULL CHECK(new_price_minor_units >= 0)` | المبلغ الجديد بالوحدة الصغرى للعملة |
| `currency_code` | `TEXT` | `String` | `NOT NULL` | رمز العملة وفق ISO 4217 |
| `changed_at` | `INTEGER` | `DateTime` | `NOT NULL` | الطابع الزمني لتاريخ سريان السعر الجديد (مفهرس مع معرّف الاشتراك) |

---

### 3-2-4 جدول إعدادات وتفضيلات التطبيق (`settings`)
جدول أحادي السجل (Singleton Table) يخزن تفضيلات المستخدم العامة وحالة البيئة المحلية.

| اسم الحقل | نوع SQLite | نوع Dart / Drift | القيود (Constraints) | الوصف الهندسي والوظيفي |
|---|---|---|---|---|
| `id` | `TEXT` | `String` | `PRIMARY KEY` | قيمة مفتاحية ثابتة دائماً: `'app_settings'` لضمان أحادية السجل |
| `theme_mode` | `TEXT` | `String` | `NOT NULL DEFAULT 'system'` | سمة الواجهة (`system`, `light`, `dark`) |
| `default_currency`| `TEXT` | `String` | `NOT NULL DEFAULT 'USD'` | العملة الافتراضية للتطبيق وفق ISO 4217 |
| `default_reminder_days`| `INTEGER`| `int` | `NOT NULL DEFAULT 1 CHECK(default_reminder_days BETWEEN 0 AND 30)` | مهلة التنبيه الافتراضية للاشتراكات الجديدة |
| `default_reminder_hour`| `INTEGER`| `int` | `NOT NULL DEFAULT 9 CHECK(default_reminder_hour BETWEEN 0 AND 23)` | ساعة التنبيه الافتراضية (0-23) |
| `default_reminder_minute`| `INTEGER`| `int` | `NOT NULL DEFAULT 0 CHECK(default_reminder_minute BETWEEN 0 AND 59)` | دقيقة التنبيه الافتراضية (0-59) |
| `default_sort_order` | `TEXT` | `String` | `NOT NULL DEFAULT 'due_date_asc'` | معيار الترتيب الافتراضي لقائمة الاشتراكات |
| `last_backup_at` | `INTEGER` | `DateTime?`| `NULL` | وقت آخر عملية تصدير نسخة احتياطية ناجحة |
| `schema_version` | `INTEGER` | `int` | `NOT NULL DEFAULT 2` | رقم إصدار المخطط المسجل لأغراض التحقق الداخلي |
| `updated_at` | `INTEGER` | `DateTime` | `NOT NULL` | طابع زمني لآخر تعديل في إعدادات التطبيق |

---

## 3-3 العلاقات والقيود التناغمية (Relationships & Integrity Constraints)

```
┌─────────────────────────┐                ┌───────────────────────────────┐
│       categories        │                │         subscriptions         │
├─────────────────────────┤                ├───────────────────────────────┤
│ PK  id                  │◄───────┐       │ PK  id                        │
│     name (UNIQUE)       │        │       │     name                      │
│     color_value         │        │1      │     price_minor_units         │
│     icon_code           │        │       │     currency_code             │
│     is_system           │        │       │     cycle_type                │
│     created_at          │        │       │     original_anchor_day       │
└─────────────────────────┘        │       │     next_due_date (INDEXED)   │
                                   └───────┤ FK  category_id (RESTRICT)    │
                                          N│     status (INDEXED)          │
                                           │     reminder_enabled          │
                                           │     created_at                │
                                           └───────────────┬───────────────┘
                                                           │1
                                                           │
                                                           │ CASCADE
                                                           │
                                                          N▼
                                           ┌───────────────────────────────┐
                                           │         price_history         │
                                           ├───────────────────────────────┤
                                           │ PK  id                        │
                                           │ FK  subscription_id (CASCADE) │
                                           │     old_price_minor_units     │
                                           │     new_price_minor_units     │
                                           │     currency_code             │
                                           │     changed_at (INDEXED)      │
                                           └───────────────────────────────┘
```

1. **علاقة التصنيف بالاشتراكات (`categories` 1 ── N `subscriptions`):**
   - الرابط: `subscriptions.category_id` يُشير إلى `categories.id`.
   - سياسة الحذف (`ON DELETE RESTRICT`): يُمنع حذف أي فئة ترتبط باشتراكات نشطة أو مؤرشفة أو في سلة المحذوفات. وفي منطق التطبيق، عند رغبة المستخدم في حذف فئة مخصصة، تتولى حالة الاستخدام (`UseCase`) نقل كافة اشتراكاتها تلقائياً وبمعاملة ذرية واحدة (`Transaction`) إلى فئة النظام الافتراضية («غير مصنّف» / `is_system = 1`) قبل تنفيذ حذف الفئة المفرغة.
2. **علاقة الاشتراك بسجل الأسعار (`subscriptions` 1 ── N `price_history`):**
   - الرابط: `price_history.subscription_id` يُشير إلى `subscriptions.id`.
   - سياسة الحذف (`ON DELETE CASCADE`): عند اتخاذ قرار الحذف النهائي والتطهير للاشتراك من سلة المهملات (`Purge`)، يتم تلقائياً حذف سجل تاريخ الأسعار التابع له للحفاظ على سلامة التخزين ومنع السجلات اليتيمة (Orphan Records).
3. **تفعيل قيود المفاتيح الأجنبية في SQLite:**
   - بما أن محرك SQLite يُعطل فحص المفاتيح الأجنبية افتراضياً للتوافقية القديمة، يُلزم كود الاتصال في `beforeOpen` بإطلاق الأمر الإلزامي:
     ```sql
     PRAGMA foreign_keys = ON;
     ```

---

## 3-4 الفهارس واستراتيجية تحسين الأداء (Indexes & Performance Optimization)

لتحقيق متطلب الأداء الصارم **NFR-01** (تنفيذ أي استعلام محلي أو فرز خلال زمن استجابة يقل عن 100 مللي ثانية حتى مع آلاف السجلات)، تم تصميم الفهارس التالية بدقة:

| اسم الفهرس | الجدول المستهدف | الأعمدة المفهرسة | التعليل والهدف الهندسي |
|---|---|---|---|
| `idx_subscriptions_due_date` | `subscriptions` | `next_due_date ASC` | تسريع استعلام الشاشة الرئيسية لشريط الاستحقاقات القادمة، والفرز الافتراضي، وجدولة التنبيهات |
| `idx_subscriptions_category_id` | `subscriptions` | `category_id` | تسريع تصفية الاشتراكات حسب التصنيف وحساب مجاميع المصروفات لكل فئة في شاشة التحليلات |
| `idx_subscriptions_status` | `subscriptions` | `status` | استبعاد الاشتراكات المؤرشفة والمحذوفة من كل استعلام عرض رئيسي (`WHERE status = 'active'`) |
| `idx_subscriptions_dup_check` | `subscriptions` | `(name, cycle_type, next_due_date)` | تسريع فحص التكرار غير الحاجز (`EC-24`) أثناء كتابة المستخدم للاشتراك الجديد دون قفل الجدول |
| `idx_price_history_sub` | `price_history` | `(subscription_id, changed_at DESC)` | تسريع جلب وتصيير الرسم البياني لتغيرات أسعار اشتراك محدد مرتبة زمنياً من الأحدث إلى الأقدم |
| `idx_categories_name` | `categories` | `name UNIQUE` | تسريع التحقق من عدم تكرار أسماء الفئات وضمان فرادتها على مستوى القاعدة |

---

## 3-5 سياسة حوكمة وترقية المخطط دون فقدان بيانات (Schema Migration Strategy & Zero Data Loss)

### 3-5-1 مبادئ الترقية والحوكمة
1. **أحادية الترقية وعدم الرجوع (Monotonic Versioning):** يرتفع رقم `schemaVersion` بمقدار 1 مع كل تحديث يمس الجداول أو الأعمدة أو الفهارس. يُحظر كلياً تعديل دالة ترقية سابقة تم نشرها في بيئة الإنتاج مهما بدت خاطئة، بل تُصحَّح بترقية تالية صريحة.
2. **الضمان الصارم لعدم فقدان البيانات (Zero Data Loss Guarantee):** أي تعديل على المخطط يجب أن يُحافظ على 100% من السجلات الموجودة مسبقاً لدى المستخدمين مع الاحتفاظ بالقيم الافتراضية المناسبة للأعمدة الجديدة.
3. **الترقية داخل معاملة ذرية (Transactional Upgrades):** تُنفَّذ جميع خطوات الترقية داخل معاملة SQLite واحدة؛ بحيث إذا فشلت أي خطوة أو قوطع التطبيق لأي سبب بيئي (مثل نفاد البطارية)، تتراجع القاعدة تلقائياً إلى الحالة السليمة السابقة دون تلف المخطط.
4. **تهيئة المحرك في `beforeOpen`:**
   - تفعيل وضع السجل المتقدم للكتابة السريعة ومنع القفل:
     ```sql
     PRAGMA journal_mode = WAL;
     PRAGMA synchronous = NORMAL;
     PRAGMA foreign_keys = ON;
     ```

### 3-5-2 أنماط الترقية (Migration Patterns)
- **النمط التراكمي (Additive Migration):** لإضافة عمود جديد يقبل قيماً فارغة أو له قيمة افتراضية، أو لإنشاء جدول جديد وفهارس جديدة. يُستخدم فيه مباشرة:
  ```dart
  await m.addColumn(table, table.newColumn);
  await m.createTable(newTable);
  ```
- **نمط النسخ والإحلال (Copy-and-Swap Pattern):** للتعديلات الهيكلية غير المدعومة مباشرة في SQLite (مثل حذف عمود، أو تعديل نوع عمود، أو تغيير قيود المفاتيح):
  1. إنشاء جدول مؤقت بالبنية الجديدة: `CREATE TABLE new_subscriptions (...);`
  2. نسخ البيانات القديمة مع التعيين: `INSERT INTO new_subscriptions SELECT ... FROM subscriptions;`
  3. إسقاط الجدول القديم: `DROP TABLE subscriptions;`
  4. إعادة تسمية الجدول المؤقت: `ALTER TABLE new_subscriptions RENAME TO subscriptions;`
  5. إعادة بناء كافة الفهارس والقيود المرتبطة بالجدول.

---

## 3-6 سيناريو ترقية تجريبي ناجح من الإصدار 1 إلى الإصدار 2 (Migration V1 -> V2 Scenario)

لتأكيد الجاهزية الهندسية وحوكمة الترقية، يُوثق السيناريو التالي لترقية التطبيق من الإصدار المبدئي 1 إلى الإصدار 2 دون أدنى فقدان للبيانات:

### 3-6-1 تعريف الفروق الهيكلية بين الإصدارين
- **الإصدار 1 (Schema V1):** يحتوي الجداول الأساسية الثلاثة فقط (`categories`, `subscriptions`, `price_history`) بدون حقل وصف وسيلة الدفع في جدول الاشتراكات، وبدون جدول الإعدادات.
- **الإصدار 2 (Schema V2):**
  1. إضافة عمود `payment_method_desc TEXT NULL` إلى جدول `subscriptions` لتمكين توثيق بطاقة الدفع (`US-04`).
  2. إنشاء جدول الإعدادات والتفضيلات الموحد (`settings`) مع غرس السجل الافتراضي الأحادي (`'app_settings'`).

### 3-6-2 كود الترقية المعتمد عبر Drift MigrationStrategy
```dart
// lib/core/database/app_database.dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    // إنشاء جميع الجداول والفهارس للإصدار الجديد
    await m.createAll();
    // غرس الفئة النظامية «غير مصنّف»
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: 'system_uncategorized_id',
        name: 'غير مصنّف',
        colorValue: 0xFF9CA3AF,
        iconCode: const Value('folder_outline'),
        isSystem: const Value(true),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    // غرس السجل الأحادي الافتراضي للإعدادات
    await into(settings).insert(
      SettingsCompanion.insert(
        id: 'app_settings',
        themeMode: const Value('system'),
        defaultCurrency: const Value('USD'),
        defaultReminderDays: const Value(1),
        defaultReminderHour: const Value(9),
        defaultReminderMinute: const Value(0),
        defaultSortOrder: const Value('due_date_asc'),
        schemaVersion: const Value(2),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // 1. إضافة العمود الجديد إلى جدول الاشتراكات دون مساس بالبيانات القديمة
      await m.addColumn(subscriptions, subscriptions.paymentMethodDesc);

      // 2. إنشاء جدول الإعدادات والتفضيلات الجديد
      await m.createTable(settings);

      // 3. غرس السجل الأحادي للإعدادات بقيمه الافتراضية
      await into(settings).insert(
        SettingsCompanion.insert(
          id: 'app_settings',
          themeMode: const Value('system'),
          defaultCurrency: const Value('USD'),
          defaultReminderDays: const Value(1),
          defaultReminderHour: const Value(9),
          defaultReminderMinute: const Value(0),
          defaultSortOrder: const Value('due_date_asc'),
          schemaVersion: const Value(2),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  },
  beforeOpen: (OpeningDetails details) async {
    await customStatement('PRAGMA foreign_keys = ON;');
    await customStatement('PRAGMA journal_mode = WAL;');
    await customStatement('PRAGMA synchronous = NORMAL;');
  },
);
```

### 3-6-3 أوامر SQLite DDL المكافئة المنفذة في الترقية
```sql
-- الترقية التراكمية من V1 إلى V2
-- 1. إضافة عمود وسيلة الدفع
ALTER TABLE subscriptions ADD COLUMN payment_method_desc TEXT NULL;

-- 2. إنشاء جدول الإعدادات
CREATE TABLE IF NOT EXISTS settings (
    id TEXT NOT NULL PRIMARY KEY,
    theme_mode TEXT NOT NULL DEFAULT 'system',
    default_currency TEXT NOT NULL DEFAULT 'USD',
    default_reminder_days INTEGER NOT NULL DEFAULT 1 CHECK(default_reminder_days BETWEEN 0 AND 30),
    default_reminder_hour INTEGER NOT NULL DEFAULT 9 CHECK(default_reminder_hour BETWEEN 0 AND 23),
    default_reminder_minute INTEGER NOT NULL DEFAULT 0 CHECK(default_reminder_minute BETWEEN 0 AND 59),
    default_sort_order TEXT NOT NULL DEFAULT 'due_date_asc',
    last_backup_at INTEGER NULL,
    schema_version INTEGER NOT NULL DEFAULT 2,
    updated_at INTEGER NOT NULL
);

-- 3. غرس السجل الافتراضي الأحادي
INSERT OR IGNORE INTO settings (
    id, theme_mode, default_currency, default_reminder_days,
    default_reminder_hour, default_reminder_minute, default_sort_order,
    schema_version, updated_at
) VALUES (
    'app_settings', 'system', 'USD', 1, 9, 0, 'due_date_asc', 2, strftime('%s', 'now') * 1000
);
```

### 3-6-4 مصفوفة التحقق واختبار عدم فقدان البيانات (Migration Verification Test Contract)
يتم التحقق الآلي من نجاح الترقية في مسار الاختبارات (`test/unit/data/migrations/migration_v1_to_v2_test.dart`) وفق السيناريو الصارم التالي:

1. **التهيئة (Arrange):**
   - إنشاء قاعدة بيانات تجريبية في الذاكرة (`NativeDatabase.memory()`) وفق مخطط **الإصدار 1**.
   - غرس بيانات حية تجريبية:
     * 3 فئات في `categories` (فئة النظام وفئتان مخصصتان).
     * 5 اشتراكات في `subscriptions` بمبالغ ووحدات صغرى متنوعة ودوريات مختلفة (`monthly`, `custom`, `yearly`).
     * سجلين لتغير الأسعار في `price_history`.
2. **التنفيذ (Act):**
   - فتح الاتصال وتفعيل الترقية إلى **الإصدار 2** عبر استدعاء `database.customStatement('PRAGMA user_version = 2;')` وتنفيذ ترقية Drift.
3. **التأكيد والتحقق (Assert - Zero Data Loss Verification):**
   - **فحص الاشتراكات:** قراءة جميع الاشتراكات الـ 5 والتأكد من تطابق المعرفات والأسماء ومبالغ الوحدات الصغرى (`price_minor_units`) وتواريخ الاستحقاق بنسبة 100%.
   - **فحص العمود الجديد:** التأكد من أن حقل `payment_method_desc` متاح للقراءة في الاشتراكات القديمة وتكون قيمته `NULL` دون أي انهيار.
   - **إمكانية الكتابة والتعديل:** تحديث اشتراك قديم وإسناد قيمة للعمود الجديد (`payment_method_desc = 'Visa 4242'`) والتأكد من حفظها واسترجاعها بنجاح.
   - **فحص جدول الإعدادات:** استعلام جدول `settings` والتأكد من وجود السجل الافتراضي الأحادي `'app_settings'` بالقيم الافتراضية الصحيحة.
   - **فحص قيود السلامة:** محاولة إدخال سجل غير صالح في `settings` والتأكد من رفضه عبر قيود `CHECK`.

---

# 4. تدفق البيانات

يبدأ المسار من حدث في الواجهة، فينتقل إلى حائز الحالة، الذي يستدعي حالة الاستخدام المناسبة، التي تستدعي واجهة المستودع المجردة، التي ينفّذها المستودع الفعلي في طبقة البيانات، الذي يستدعي مصدر البيانات، الذي يستدعي كائن الوصول، الذي يخاطب القاعدة. ثم يعود المسار: يُرجع كائن الوصول صفوفاً أو يرمي استثناءً، فيحوّل المستودع الصفوف إلى كيانات والاستثناء إلى إخفاق، فتُرجع حالة الاستخدام نتيجة تحمل أحد الأمرين، فيحوّلها حائز الحالة إلى حالة عرض، فتعرض الواجهة واحدة من حالاتها الأربع.

**قاعدة ثابتة:** لكل شاشة أربع حالات لا ثلاث: عرض البيانات، والتحميل، والفراغ، والخطأ. والشاشة التي تنقصها حالة الفراغ ستعرض بياضاً يظنه المستخدم عطلاً.

---

# 5. إدارة الحالة والأداء

تُبنى الواجهة على مصدر حالة واحد لكل شاشة، ولا تُكرَّر حالة واحدة في موضعين لأن التكرار يعني التناقض عاجلاً أو آجلاً. وتُبنى القوائم بناءً كسولاً لا يُنشئ إلا ما يظهر على الشاشة. وتُجرى الحسابات الثقيلة مرة واحدة وتُخزَّن نتيجتها حتى تتغير مدخلاتها، فلا يُعاد حساب لوحة الملخص مع كل إطار. ولا يُشغَّل أي عمل ثقيل على الخيط الرئيسي، وما يتجاوز منه حداً زمنياً يُنقل إلى خيط منفصل حتى لا تتجمد الواجهة.

---

# 6. إدارة الأخطاء

تُقسَّم الأخطاء ثلاثة أنواع. **أخطاء متوقعة** كإدخال غير صالح أو سجل غير موجود، وتُمثَّل بإخفاقات دومين وتُعرض للمستخدم برسالة مفهومة وإجراء تصحيحي. و**أخطاء بيئية** كامتلاء التخزين أو قفل القاعدة أو تلف ملفها، وتُعالَج بإعادة محاولة أو بمسار تعافٍ صريح. و**أخطاء برمجية** ناتجة عن خلل في الشيفرة، وهذه لا تُخفى ولا تُبتلع، بل تُسجَّل وتُعرض بشاشة خطأ عامة، لأن إخفاءها يجعلها تتكرر صامتة إلى الأبد.

وفي جميع الأحوال لا يُعرض للمستخدم نص استثناء تقني، ولا تُسجَّل قيمة مالية في سجلات التصحيح في وضع الإنتاج.

---

# 7. إرشادات التوسّع المستقبلي

**إضافة المزامنة السحابية:** يُضاف مصدر بيانات بعيد إلى طبقة البيانات، ويُوسَّع تنفيذ المستودع ليوفّق بين المحلي والبعيد، وتُضاف أعمدة بيانات مزامنة عبر ترقية مخطط، وتُحدَّد سياسة حل التعارض صراحة. ولا تُمسّ طبقتا الدومين والعرض. وإن اضطر أحد إلى المساس بهما فذلك دليل على خلل في التجريد لا مبرر لتجاوزه.

**إحلال محرك تخزين آخر:** تُستبدل الجداول وكائنات الوصول ومصادر البيانات، ويبقى العقد العام للمستودع كما هو. ومعيار نجاح الإحلال أن تمر اختبارات الدومين دون تعديل حرف واحد فيها.

**إضافة وحدة وظيفية جديدة:** تُنشأ بالبنية الثلاثية نفسها داخل مجلدها الخاص، ويوضع المشترك في النواة، ولا تستورد وحدة من وحدة أخرى مباشرة.

**إضافة منصة جديدة:** العمل كله في طبقة العرض، وتتغير فقط طريقة إنشاء القاعدة بحسب المنصة.

---

# 8. المصطلحات التقنية

**جذر التركيب:** الموضع الوحيد الذي تُوصل فيه التنفيذات الفعلية بالواجهات المجردة.
**كائن القيمة:** نوع يحمي ثوابته ذاتياً فلا يمكن إنشاؤه في حالة غير صالحة.
**الترسيخ على اليوم الأصلي:** الاحتفاظ باليوم الذي بدأ منه الالتزام والرجوع إليه بعد كل شهر قصير.
**الوحدة الصغرى للعملة:** أصغر وحدة قابلة للتمثيل الصحيح، وتُخزَّن بها المبالغ منعاً لخطأ الأعداد العائمة.
