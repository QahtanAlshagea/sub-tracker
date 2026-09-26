# 05-implementation.md — تفاصيل الشيفرة والتنفيذ البرمجي
## المهمة: C-10 — محرك الحسابات المالية والتحليلات
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. محرك الحسابات النقي `FinancialCalculator`
- فئة نقية تحتوي على دوال ثابتة (Static Pure Functions) خالية من أي حالة داخلية (Stateless):
  - `computeMonthlyEquivalent(Money price, BillingCycle cycle)`: حساب التكلفة الشهرية المكافئة بدقة متناهية وفق قواعد التقريب نصف-لأعلى.
  - `computeAnnualEquivalent(Money price, BillingCycle cycle)`: حساب التكلفة السنوية.
  - `calculateMonthlySummaries(List<Subscription> subscriptions)`: تجميع الاشتراكات حسب رمز العملة، وإنشاء كائن `MonthlySummary` مستقل لكل عملة يحتوي على: إجمالي الشهر، إجمالي السنة، متوسط التكلفة، وعدد السجلات.
  - `calculateCalendarMonthProjection(List<Subscription> subscriptions, DateTime targetMonth)`: رصد كافة الدفعات المستحقة داخل الشهر المستهدف مع تمييز الدفعات المتأخرة `isOverdue`.
  - `calculateRolling30DaysProjection(List<Subscription> subscriptions, DateTime startDate)`: رصد كافة الاستحقاقات التي تقع خلال الـ 30 يوماً القادمة.
  - `findHighestCostSubscription(List<Subscription> subscriptions, {String? currencyCode})`: استخراج الاشتراك صاحب التكلفة الشهرية الأعلى ونسبته المئوية وفض التعادل حتمياً.
  - `calculateCategoryDistribution(List<Subscription> subscriptions, List<Category> categories, String currencyCode)`: توزيع الإنفاق حسب الفئات وتحديد فئة "غير مصنّف" للاشتراكات غير المربوطة.
  - `compareMonthOverMonth(...)`: حساب الفارق المالي ونسبة التغير واتجاه الإنفاق (`SpendTrend.increased`, `decreased`, `constant`, `newSpending`).

---

## 2. كائنات التحليلات (Domain Entities)
- `MonthlySummary`: يجمع إحصائيات عملة واحدة.
- `PaymentOccurrence`: يمثل استحقاقاً مالياً في تاريخ محدد.
- `UpcomingProjection`: يحمل نتائج التوقعات وإجمالي المبالغ المستحقة.
- `HighestCostSubscriptionResult`: يحمل تفاصيل الاشتراك الأعلى كلفة ونسبته.
- `CategoryDistributionResult`: يحمل قائمة الفئات ونسب توزيع الإنفاق.
- `MonthComparisonResult`: يحمل بيانات المقارنة الشهرية والاتجاه.

---

## 3. حالات الاستخدام (UseCases) المنفذة
- `GetMonthlySummaryUseCase`
- `GetUpcomingProjectionsUseCase`
- `GetHighestCostSubscriptionUseCase`
- `GetCategoryDistributionUseCase`
- `GetMonthComparisonUseCase`
- جميعها تعتمد على `SubscriptionRepository` لاسترجاع البيانات النشطة، ثم تمريرها إلى `FinancialCalculator` لإجراء الحسابات وإرجاع كائنات `Result<T>` جاهزة للاستهلاك في واجهات المستخدم.
