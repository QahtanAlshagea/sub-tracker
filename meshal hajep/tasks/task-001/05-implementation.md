# 05-implementation.md — خطوات التنفيذ وبناء مجموعات الفحص
## المهمة: C-18 — منظومة الاختبار الشاملة ومصفوفة حالات الحافة
### المهندس: مشعل حاجب (Meshal Hajeb — @mshalhajep)

---

## 1. الخطوات البرمجية المنجزة

تم تنفيذ المهمة على 4 محاور تقنية رئيسية:

### أ. بناء مجموعات اختبارات الكيانات ونماذج النتائج (Domain Models Suite)
تمت كتابة وتوسيع اختبارات الوحدة لنماذج الكيانات والنتائج الثمانية في الدومين:
- `backup_data_test.dart` و `backup_preview_test.dart`
- `category_distribution_item_test.dart`
- `highest_cost_subscription_result_test.dart`
- `month_comparison_result_test.dart`
- `monthly_summary_test.dart`
- `payment_occurrence_test.dart`
- `upcoming_projection_test.dart`

### ب. بناء مصفوفة استعلامات الفرز والبحث (Query Matrix & Edge Cases)
- بناء ملف `query_matrix_test.dart` لفحص كافة التوافيق والتباديل لخيارات البحث، الفرز (الأقرب استحقاقاً، الأعلى كلفة، الأحدث إضافة)، والتصفية بحسب الحالة (النشطة، المتأخرة overdue، المسددة).
- بناء `subscription_lifecycle_edge_cases_test.dart` لتغطية دورة حياة الاشتراكات والتجديد والأرشفة.

### ج. فحص صلابة التخزين والتراجع التلقائي (Database Resilience Suite)
- بناء `database_resilience_test.dart` لمحاكاة الأعطال:
  - محاكاة أخطاء القفل والمحاولات المتكررة (concurrency/backoff).
  - التحقق من فشل المعاملة والتراجع الذري الشامل (**Atomic Rollback**).
  - التحقق من رفض إدخال مبالغ غير متوافقة في قاعدة البيانات.

### د. بناء مصفوفة اختبارات الواجهة والمكونات (Widget Edge Cases Matrix)
- بناء `home_and_list_edge_cases_test.dart`: فحص القوائم الكبيرة (Lazy Loading)، اتجاه النصوص ثنائي اللغة (Bidi Directionality)، والتحديث اللحظي للتواريخ عند منتصف الليل.
- بناء `add_edit_and_settings_edge_cases_test.dart`: فحص النقر المزدوج السريع، تدوير الجهاز وحفظ حالة الحقول، وتأكيد مسح البيانات الدفاعي بكتابة كلمة "مسح".
- بناء `price_history_and_details_edge_cases_test.dart`: فحص شاشة التفاصيل وسجل الدفعات الزمني.

---

## 2. مطابقة المعرفات الصريحة `[EC-XX-Y]`
تمت كتابة وتسمية جميع دوال الاختبار بصيغة تحتوي على المعرف المباشر لحالة الحافة، مثال:
```dart
test('US-05 / [EC-01-1]: month-end 31st clamps to 28th in February and restores in March', () {
  // Logic verification
});

test('US-12 / [EC-12-3]: double tap on delete confirmation does not trigger duplicate deletion', (tester) async {
  // Widget verification
});
```
