# 05-implementation.md — تفاصيل الشيفرة والتنفيذ البرمجي
## المهمة: C-07 — الكيانات وكائنات القيمة في طبقة الدومين
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. كائنات القيمة المبنية (Value Objects)

### أ. كائن القيمة المالي `Money` (`lib/features/subscriptions/domain/value_objects/money.dart`)
- تخزين المبلغ كعدد صحيح 64-بت `final int amountMinorUnits` (سنتات أو فلسات).
- حفظ رمز العملة `final String currencyCode` وفق المعيار الدولي `ISO 4217`.
- منشئات مساعدة للمبالغ العشرية المعتادة (مثل `fromDecimal(9.99, 'USD')` -> `999`).
- دوال العمليات الحسابية الآمنة: `add(Money other)` و `subtract(Money other)` مع فحص تطابق العملات وإلقاء استثناء عند الخلط `[EC-15-1]`.
- منع القيم السالبة في المنشئ `[EC-01-1]`.

### ب. كائن دورة الفوترة `BillingCycle` (`lib/features/subscriptions/domain/value_objects/billing_cycle.dart`)
- صنف مختوم/تعداد يدعم الأنواع: `weekly`, `monthly`, `yearly`, `custom`.
- في النمط المخصص: التحقق من أن عدد الأيام يقع بين 1 و 3650 يوماً `[EC-02-1]`.
- دوال مساعدة لحساب التكرار السنوي والمعامل الشهري بدقة.

### ج. كائن تاريخ الاستحقاق `DueDate` (`lib/features/subscriptions/domain/value_objects/due_date.dart`)
- حفظ التاريخ الحالي المعتمد `final DateTime nextDate`.
- حفظ اليوم الأصلي المثبت `final int originalAnchorDay` (بين 1 و 31).
- دالة `computeNextOccurrence(BillingCycle cycle)` التي تعود دائماً لليوم الأصلي `originalAnchorDay` لحساب الشهر اللاحق وتشذيبه إلى آخر يوم متاح في الشهر عند اللزوم، دون فقدان اليوم الأصلي `[EC-03-1]`.

### د. كائن حالة الاشتراك `SubscriptionStatus` (`lib/features/subscriptions/domain/value_objects/subscription_status.dart`)
- تعداد يمثل الحالات الثلاث: `active`, `archived`, `inTrash`.

---

## 2. الكيانات المبنية (Domain Entities)

### أ. كيان الاشتراك `Subscription` (`lib/features/subscriptions/domain/entities/subscription.dart`)
- يحتوي على: المعرف الفريد `id`، الاسم `name`، السعر ككائن `Money`، الدورة ككائن `BillingCycle`، الاستحقاق ككائن `DueDate`، معرف الفئة `categoryId`، الحالة `SubscriptionStatus`، راية التجربة المجانية `isTrial`، الملاحظات، رابط التجديد، إعدادات التنبيه، والطوابع الزمنية.
- غير قابل للتعديل (Immutable) مع توفير دالة `copyWith`.

### ب. كيان الفئة `Category` (`lib/features/subscriptions/domain/entities/category.dart`)
- يحتوي على: المعرف `id`، الاسم `name`، القيمة اللونية `colorValue`، رمز الأيقونة `iconCode`، وراية فئة النظام المحمية `isSystem`.

### ج. كيان سجل الأسعار `PriceHistoryEntry` (`lib/features/subscriptions/domain/entities/price_history_entry.dart`)
- يحتوي على: معرف القيد `id`، معرف الاشتراك `subscriptionId`، السعر القديم والجديد ككائنات `Money`، وتاريخ التغيير `changedAt`.
