# 05-implementation.md — تفاصيل الشيفرة والتنفيذ البرمجي
## المهمة: C-09 — واجهات المستودعات وحالات الاستخدام
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. واجهات المستودعات المجردة (Repository Contracts)

### أ. واجهة مستودع الاشتراكات `SubscriptionRepository`
- توابع الإضافة والتعديل والحذف:
  - `Future<Result<Subscription>> addSubscription(Subscription subscription)`
  - `Future<Result<Subscription>> updateSubscription(Subscription subscription)`
  - `Future<Result<void>> moveToTrash(String id)`
  - `Future<Result<void>> restoreFromTrash(String id)`
  - `Future<Result<void>> permanentDelete(String id)`
  - `Future<Result<void>> archive(String id)`
  - `Future<Result<void>> unarchive(String id)`
  - `Future<Result<void>> purgeTrash()`
  - `Future<Result<Subscription>> renewSubscription(String id)`
- توابع الاستعلام وبث التدفقات:
  - `Future<Result<Subscription>> getSubscriptionById(String id)`
  - `Stream<Result<List<Subscription>>> watchSubscriptions({SubscriptionFilter? filter})`

### ب. واجهة مستودع الفئات `CategoryRepository`
- توابع إدارة الفئات:
  - `Future<Result<Category>> addCategory(Category category)`
  - `Future<Result<Category>> updateCategory(Category category)`
  - `Future<Result<void>> deleteCategory(String id, {String? reassignToCategoryId})`
  - `Stream<Result<List<Category>>> watchCategories()`

---

## 2. حالات الاستخدام (UseCases) المنفذة
- تطبيق مبدأ المسؤولية الواحدة (SRP): تم بناء كل UseCase في ملف منفصل ومستقل.
- كل UseCase يرث من الصنف الأساسي العام `UseCase<Type, Params>` أو `StreamUseCase<Type, Params>` في النواة المشتركة.
- كل عملية تتأكد من تمرير البيانات لمحرك التحقق `SubscriptionValidator` قبل مناداة المستودع، بحيث يتم اعتراض الأخطاء مبكراً قبل وصولها لطبقة البيانات.
