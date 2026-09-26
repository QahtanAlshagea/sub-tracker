# 03-plan.md — خطة التنفيذ وتوزيع ملفات الفحص
## المهمة: C-18 — منظومة الاختبار الشاملة ومصفوفة حالات الحافة
### المهندس: مشعل حاجب (Meshal Hajeb — @mshalhajep)

---

## 1. مراحل التنفيذ المتتابعة

```text
[المرحلة 1: إعداد البيئة والبدائل]
       │
       ▼
- بناء FakeSubscriptionRepository و FakeCategoryRepository
- إعداد مسارات الاختبار في test/unit/ و test/widget/
       │
       ▼
[المرحلة 2: كتابة اختبارات الوحدة للدومين والبيانات]
       │
       ▼
- اختبارات الكيانات وكائنات القيمة (Money, DueDate, BillingCycle)
- اختبارات الحسابات المالية (FinancialCalculator, AnalyticsUseCases)
- اختبارات كائنات DAOs والمعاملات الذرية ومحاكاة انقطاع الطاقة
       │
       ▼
[المرحلة 3: كتابة اختبارات الواجهة والمكونات]
       │
       ▼
- اختبار الحالات الأربع لشاشات: Home, AddEdit, Summary, Settings, Details
- اختبارات التدوير والتغذية اللمسية وشريط التراجع
       │
       ▼
[المرحلة 4: تدقيق مصفوفة حالات الحافة وبوابات الجودة]
       │
       ▼
- ربط 151 حالة حافة بمعرفاتها الصريحة [EC-XX-Y] في أسماء الدوال
- التحقق من تغطية الدومين (>=85%) وتغطية البيانات (>=70%)
- التحقق من تشغيل flutter analyze --fatal-infos بنظافة تامة
```

---

## 2. جدول توزيع ملفات الاختبار المقترحة

| المرحلة | ملفات الاختبار | الهدف البرمجي |
|---|---|---|
| **Domain Entities** | `test/unit/features/.../domain/entities/*_test.dart` | فحص اتساق كائنات الدومين وعزل العملات وحسابات الإجمالي. |
| **Validators & Engines** | `test/unit/features/.../domain/validators/*_test.dart` | فحص تثبيت التقويم، كشف التكرار، والتحقق من المدخلات. |
| **UseCases & Matrix** | `test/unit/features/.../domain/usecases/query_matrix_test.dart` | فحص مصفوفة الاستعلامات المتعددة، والفرز والتصفية. |
| **Data Resilience** | `test/unit/features/.../data/datasources/database_resilience_test.dart` | فحص صلابة التخزين والتراجع التلقائي عند انقطاع المعاملات. |
| **Widget 4-States** | `test/widget/features/.../screens/*_test.dart` | فحص حالات Data, Loading, Empty, Error لكافة الشاشات. |
| **Edge Cases Matrix** | `test/widget/features/.../screens/*_edge_cases_test.dart` | فحص الحالات الحدية للواجهة والمستخدم وتدوير الشاشة. |
