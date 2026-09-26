# 03-plan.md — خطة التنفيذ وعقد الاختبارات (Test Contract)
## المهمة: C-07 — الكيانات وكائنات القيمة في طبقة الدومين
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. خطة الملفات المستهدفة بالإنشاء
1. `lib/features/subscriptions/domain/value_objects/money.dart`
2. `lib/features/subscriptions/domain/value_objects/billing_cycle.dart`
3. `lib/features/subscriptions/domain/value_objects/due_date.dart`
4. `lib/features/subscriptions/domain/value_objects/subscription_status.dart`
5. `lib/features/subscriptions/domain/entities/subscription.dart`
6. `lib/features/subscriptions/domain/entities/category.dart`
7. `lib/features/subscriptions/domain/entities/price_history_entry.dart`

---

## 2. عقد الاختبارات الإلزامي (Test Contract)
يتم وضع كافة الاختبارات في ملفات مرآتية مطابقة لمسار `lib/` في `test/unit/features/subscriptions/domain/`:
1. **اختبارات كائن المال `money_test.dart`:**
   - `test('happy path: creates valid money object with positive amount', ...)`
   - `test('[EC-01-1]: rejects negative minor units', ...)`
   - `test('[EC-01-2]: handles max ceiling limit without overflow', ...)`
   - `test('[EC-15-1]: forbids addition of different currencies', ...)`
   - `test('supports value equality and copyWith', ...)`
2. **اختبارات دورة الفوترة `billing_cycle_test.dart`:**
   - `test('creates weekly, monthly, and yearly cycles', ...)`
   - `test('[EC-02-1]: rejects custom cycle <= 0 or > 3650 days', ...)`
   - `test('computes annual equivalent cycle multiplier accurately', ...)`
3. **اختبارات تاريخ الاستحقاق `due_date_test.dart`:**
   - `test('maintains original anchor day', ...)`
   - `test('[EC-03-1]: clamps 31st to 28/30 days without shifting anchor day', ...)`
   - `test('[EC-03-2]: handles leap year transition accurately', ...)`
4. **اختبارات الكيانات `subscription_entity_test.dart` و `category_entity_test.dart`:**
   - `test('verifies immutable entity instantiation', ...)`
   - `test('verifies copyWith and property equality', ...)`

---

## 3. بوابات الجودة المطلوبة قبل الاعتماد (Quality Gates)
- `dart format --set-exit-if-changed .` -> نظيف بالكامل.
- `flutter analyze --fatal-infos` -> صفر مشاكل وصفر تحذيرات.
- فحص نقاء الدومين التلقائي -> عدم وجود أي استيراد لـ Flutter أو Drift في `domain/`.
- نسبة تغطية الاختبارات لطبقة الدومين $\ge 85\%$.
