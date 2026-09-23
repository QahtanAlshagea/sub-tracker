# 03-plan.md — خطة التنفيذ وعقد الاختبارات (Test Contract)
## المهمة: C-09 — واجهات المستودعات وحالات الاستخدام
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. خطة الملفات المستهدفة بالإنشاء والتعديل
1. `lib/features/subscriptions/domain/repositories/subscription_repository.dart`
2. `lib/features/subscriptions/domain/repositories/category_repository.dart`
3. 16 ملفاً مستقلاً لحالات الاستخدام في `lib/features/subscriptions/domain/usecases/`.

---

## 2. عقد الاختبارات الإلزامي (Test Contract)
توضع الاختبارات في `test/unit/features/subscriptions/domain/usecases/`:
1. **اختبارات دورة حياة الاشتراك:**
   - `test('adds subscription successfully and returns created entity', ...)`
   - `test('[EC-01-3]: rejects invalid subscription and returns ValidationFailure without hitting repo', ...)`
   - `test('updates subscription successfully', ...)`
   - `test('moves to trash and updates status', ...)`
   - `test('restores from trash successfully', ...)`
   - `test('permanently deletes subscription', ...)`
   - `test('archives and unarchives subscription', ...)`
   - `test('[EC-08-1]: renews subscription computing next due date', ...)`
2. **اختبارات الفئات:**
   - `test('adds valid category successfully', ...)`
   - `test('[EC-06-2]: blocks deleting system uncategorized category', ...)`
   - `test('reassigns subscriptions to another category', ...)`
3. **اختبارات التدفقات والاستعلامات:**
   - `test('watches subscriptions stream filtered by status', ...)`
   - `test('watches categories stream', ...)`

---

## 3. بوابات الجودة
- استخدام البدائل المولدة `MockSubscriptionRepository` و `MockCategoryRepository` عبر `package:mockito`.
- 34 اختبار وحدة مخصص لـ C-09 بنجاح 100%.
- خلو تام من أي تحذير في التحليل الساكن.
