# 03-plan.md — خطة التنفيذ وعقد الاختبارات (Test Contract)
## المهمة: C-10 — محرك الحسابات المالية والتحليلات
### المهندس: محمد العيدروس (Mohammed Al-Aidrous)

---

## 1. خطة الملفات المستهدفة بالإنشاء
1. `lib/features/subscriptions/domain/services/financial_calculator.dart`
2. كائنات التحليلات في `lib/features/subscriptions/domain/entities/`:
   - `monthly_summary.dart`
   - `payment_occurrence.dart`
   - `upcoming_projection.dart`
   - `highest_cost_subscription_result.dart`
   - `category_distribution_item.dart`
   - `category_distribution_result.dart`
   - `month_comparison_result.dart`
3. 5 حالات استخدام في `lib/features/subscriptions/domain/usecases/`.

---

## 2. جدول القيم المرجعية المعتمدة لاختبار الحسابات (Benchmark Table)

| الاشتراك | الدورة | المبلغ بالوحدات الصغرى | المكافئ الشهري المحسوب يدوياً | السنوي |
|---|---|---|---|---|
| Netflix | شهري | 1,599 سنت ($15.99) | 1,599 سنت | 19,188 سنت |
| Spotify | سنوي | 11,988 سنت ($119.88) | 999 سنت | 11,988 سنت |
| Gym | أسبوعي | 2,500 سنت ($25.00) | `(2500*52)/12 = 10,833` سنت | 130,000 سنت |
| Cloud VPS | مخصص (45 يوماً) | 4,500 سنت ($45.00) | `(4500*365)/(45*12) = 3,042` سنت | 36,500 سنت |

---

## 3. عقد الاختبارات الإلزامي (Test Contract)
توضع الاختبارات في `test/unit/features/subscriptions/domain/services/financial_calculator_test.dart` و `analytics_usecases_test.dart`:
- `test('computes monthly equivalent matching manual benchmark table', ...)`
- `test('[EC-16-1]: handles empty subscription list with zero totals', ...)`
- `test('[EC-16-2]: groups different currencies separately and never sums them together', ...)`
- `test('[EC-17-1]: calculates calendar month and rolling 30-day projection accurately', ...)`
- `test('[EC-18-2]: determines highest cost subscription and breaks ties deterministically', ...)`
- `test('[EC-19-1]: computes category spending distribution percentages totaling 100%', ...)`
- `test('[EC-20-2]: compares month over month avoiding division by zero', ...)`
