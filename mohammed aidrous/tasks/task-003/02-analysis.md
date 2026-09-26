# 02-analysis.md — التحليل الفني وحالات الحافة
## المهمة: C-09 — واجهات المستودعات وحالات الاستخدام
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. التحليل المعماري وتطبيق مبدأ DIP
- **عكس التبعية (Dependency Inversion Principle):** حالات الاستخدام تعتمد على الواجهات المجردة `SubscriptionRepository` و `CategoryRepository` كعقود غير قابلة للخرق.
- **عزل طبقة العرض والتخزين:** طبقة العرض تستدعي الـ UseCases فقط، وتستقبل كائنات `Result<T>` جاهزة دون أن تعرف شيئاً عن كيفية الحفظ أو الاستعلام.
- **التدفقات التفاعلية (Reactive Streams):** دعم واجهات `StreamUseCase` لبث تدفقات الاشتراكات والفئات بشكل لحظي عند أي تعديل.

---

## 2. مصفوفة حالات الحافة المرتبطة (Edge Cases Matrix)

| معرّف حالة الحافة | الوصف | الإجراء الهندسي الدفاعي في الـ UseCase |
|---|---|---|
| `[EC-01-5]` | النقر المزدوج السريع على زر إضافة أو تعديل الاشتراك | حماية المنطق واستخدام التحقق لمنع تكرار الإدخال. |
| `[EC-06-1]` | محاولة حذف فئة مرتبطة باشتراكات نشطة دون إعادة تعيينها | رفض الحذف المباشر وإلزام إعادة تعيين الاشتراكات لفئة أخرى أولاً. |
| `[EC-06-2]` | محاولة حذف فئة النظام المحمية ("غير مصنّف") | حظر العملية تماماً وإرجاع `SystemCategoryProtectedFailure`. |
| `[EC-10-2]` | تعديل سعر الاشتراك دون تسجيل قيد في سجل الأسعار | إلزام تسجيل قيد السعر القديم والجديد في سجل الأسعار عبر الدومين. |
| `[EC-12-1]` | الحذف بمرحلتين: النقل لسلة المحذوفات ثم الحذف النهائي | توفير `MoveToTrashUseCase` و `RestoreFromTrashUseCase` و `PermanentDeleteUseCase`. |
| `[EC-12-2]` | تفريغ سلة المحذوفات بالكامل (Purge Trash) | توفير عملية جماعية آمنة `PurgeTrashUseCase`. |

---

## 3. قائمة حالات الاستخدام الـ 16 المنفذة
1. `AddSubscriptionUseCase`
2. `UpdateSubscriptionUseCase`
3. `MoveSubscriptionToTrashUseCase`
4. `RestoreSubscriptionFromTrashUseCase`
5. `PermanentDeleteSubscriptionUseCase`
6. `ArchiveSubscriptionUseCase`
7. `UnarchiveSubscriptionUseCase`
8. `GetSubscriptionByIdUseCase`
9. `WatchSubscriptionsUseCase` (Stream)
10. `RenewSubscriptionUseCase`
11. `AddCategoryUseCase`
12. `UpdateCategoryUseCase`
13. `DeleteCategoryUseCase`
14. `WatchCategoriesUseCase` (Stream)
15. `ReassignCategoryUseCase`
16. `PurgeTrashUseCase`
