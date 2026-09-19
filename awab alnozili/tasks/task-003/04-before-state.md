# 04 - حالة المشروع قبل بدء المهمة (Before State)

## 1. مسار الواجهة المخصص للمهمة
المسار المستهدف:
`lib/features/subscriptions/presentation/`

### فحص محتويات المجلد قبل التنفيذ:
- `tokens/presentation_tokens.dart` (جاهز من C-15).
- `state/` (جاهز من C-16):
  - `subscriptions_view_state.dart`
  - `expense_summary.dart`
  - `subscriptions_controller.dart`
- `formatters/` (جاهز من C-16):
  - `subscription_formatters.dart`
- `widgets/` (جاهز من C-16):
  - `loading_shimmer_view.dart`
  - `empty_state_view.dart`
  - `error_state_view.dart`
  - `subscription_card.dart`
  - `summary_dashboard.dart`
- `screens/` (جاهز من C-16):
  - `home_screen.dart`
  - `add_edit_subscription_screen.dart`

---

## 2. النواقص المراد استيفاؤها في C-17
1. أزرار الحفظ والحذف في النموذج والشاشات لا تملك حالياً فصلاً زمنياً لحماية النقر المزدوج السريع (Debounce Guard).
2. لا يوجد حالياً دعم لحذف الاشتراك بالسحب السريع (`Dismissible`) مع شريط تراجع (`Undo SnackBar`) فوري.
3. التغذية الراجعة اللمسية (`HapticFeedback`) غير مفعلة على تفاعلات البطاقات والأزرار ومحددات الدوريات.
4. شاشة الإضافة والتعديل مصممة في نسق رأسي أحادي العمود لا يستفيد من العرض المتاح في الوضع الأفقي (`Landscape`) أو الشاشات العريضة.

---

## 3. حالة الاختبارات والتحليل الساكن
- إجمالي اختبارات المشروع الحالية: **172 اختباراً** (جميعها ناجحة 100%).
- حالة التحليل الساكن (`flutter analyze`): صفر أخطاء، صفر تحذيرات، صفر ملاحظات.
