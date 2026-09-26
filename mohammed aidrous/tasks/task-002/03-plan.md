# 03-plan.md — خطة التنفيذ وعقد الاختبارات (Test Contract)
## المهمة: C-08 — قواعد التحقق في الدومين وحساب التقويم
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. خطة الملفات المستهدفة بالإنشاء والتعديل
1. `lib/features/subscriptions/domain/validators/subscription_validator.dart`
2. `lib/features/subscriptions/domain/validators/category_validator.dart`
3. `lib/features/subscriptions/domain/validators/duplicate_detector.dart`
4. `lib/features/subscriptions/domain/validators/recurrence_calculator.dart`
5. `lib/features/subscriptions/domain/failures/subscription_failures.dart`

---

## 2. عقد الاختبارات الإلزامي (Test Contract)
توضع الاختبارات في `test/unit/features/subscriptions/domain/validators/`:
1. **اختبارات محقق الاشتراكات `subscription_validator_test.dart`:**
   - `test('validates correct subscription data successfully', ...)`
   - `test('[EC-01-3]: rejects empty name and whitespace-only name', ...)`
   - `test('[EC-01-3]: rejects name > 100 characters', ...)`
   - `test('[EC-01-4]: detects and blocks credit card numbers using Luhn check', ...)`
   - `test('[EC-01-1]: rejects negative and overflow price', ...)`
2. **اختبارات محقق الفئات `category_validator_test.dart`:**
   - `test('validates valid category name and hex color', ...)`
   - `test('rejects empty or whitespace category name', ...)`
3. **اختبارات كاشف التكرار `duplicate_detector_test.dart`:**
   - `test('[EC-04-1]: detects exact duplicate subscription names', ...)`
   - `test('[EC-04-1]: normalizes Arabic text (alif, hamza, taa marbuta, tashkeel)', ...)`
   - `test('normalizes Eastern Arabic numerals (0..9 vs ٠..٩)', ...)`
4. **اختبارات حاسبة التكرار `recurrence_calculator_test.dart`:**
   - `test('[EC-08-1]: computes next due date in O(1) for dates 10 years in the past', ...)`
   - `test('[EC-13-2]: maintains anchor day 31 across Feb and April accurately', ...)`
   - `test('[EC-14-2]: calculates leap year 29 Feb accurately', ...)`

---

## 3. بوابات الجودة
- 132 اختبار وحدة مخصص لـ C-08 بنجاح 100%.
- خلو تام من أي تحذير في التحليل الساكن (`flutter analyze --fatal-infos`).
- زمن حساب التكرار أقل من 1 مللي ثانية لكل استدعاء.
