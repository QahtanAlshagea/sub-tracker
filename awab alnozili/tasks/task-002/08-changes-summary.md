# 08 - ملخص التغييرات البرمجية (Changes Summary)

## الملفات الجديدة التي تم إنشاؤها
1. **`lib/features/subscriptions/presentation/state/subscriptions_view_state.dart`:**
   - صنف مختوم (`sealed class`) يمثل الحالات الأربع: `Loading`, `Empty`, `Data`, `Error`.
2. **`lib/features/subscriptions/presentation/state/expense_summary.dart`:**
   - حساب وتجميع المكافئ الشهري والسنوي، فصل العملات المتعددة `[EC-15-1]`، وعد الاشتراكات النشطة.
3. **`lib/features/subscriptions/presentation/state/subscriptions_controller.dart`:**
   - متحكم حالة نقي مبني على `ValueNotifier` يسهل إدارة الحالة وحقنها واختبارها.
4. **`lib/features/subscriptions/presentation/formatters/subscription_formatters.dart`:**
   - أدوات تنسيق للعملات، الدوريات، تطبيع الأرقام (٠-٩)، وتصنيف استعجال الاستحقاق.
5. **`lib/features/subscriptions/presentation/widgets/loading_shimmer_view.dart`:**
   - هيكل التحميل التفاعلي الخالي من الشاشات البيضاء.
6. **`lib/features/subscriptions/presentation/widgets/empty_state_view.dart`:**
   - مكوّن الفراغ الجذاب مع زر الإضافة `EC-05-1`.
7. **`lib/features/subscriptions/presentation/widgets/error_state_view.dart`:**
   - مكوّن الخطأ مع زر إعادة المحاولة `EC-05-4`.
8. **`lib/features/subscriptions/presentation/widgets/subscription_card.dart`:**
   - بطاقة تفاصيل الاشتراك مع الشارات والحدود الخاصة للأيام الحرجة $\le 3$ أيام واقتطاع النصوص الطويلة `EC-05-2, EC-05-5`.
9. **`lib/features/subscriptions/presentation/widgets/summary_dashboard.dart`:**
   - لوحة الملخص المالي للحالات الأربع وفصل العملات `US-15, EC-15-1`.
10. **`lib/features/subscriptions/presentation/screens/home_screen.dart`:**
    - الشاشة الرئيسية الرابطة للحالات الأربع والتحديث بالسحب والإضافة.
11. **`lib/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart`:**
    - شاشة ونموذج إضافة وتعديل الاشتراك بجميع الحقول والتحقق الدفاعي وحوار تأكيد الخروج.

## ملفات الاختبارات الجديدة (`test/widget/presentation/`)
1. `home_screen_test.dart` (5 اختبارات واجهة).
2. `subscription_card_test.dart` (6 اختبارات واجهة).
3. `summary_dashboard_test.dart` (4 اختبارات واجهة).
4. `add_edit_subscription_screen_test.dart` (7 اختبارات واجهة).

## الملفات المعدلة
1. **`lib/main.dart`:**
   - ربط `HomeScreen` كشاشة البداية الافتراضية مع السمتين والاتجاه العربي.
2. **`AI_Log.md`:**
   - إضافة السجل رقم 20 لتوثيق إنجاز المهمة `C-16`.
