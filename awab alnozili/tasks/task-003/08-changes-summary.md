# 08 - ملخص التغييرات البرمجية (Changes Summary)

## الملفات الجديدة التي تم إنشاؤها
1. **`lib/features/subscriptions/presentation/utils/debounce_guard.dart`:**
   - أداة حماية الأزرار من النقر المزدوج السريع بفاصل زمني محدد ومنع الاستدعاء المتزامن `[EC-01-5]`.
2. **`lib/features/subscriptions/presentation/utils/haptic_feedback_helper.dart`:**
   - خدمة مركزية للتغذية الراجعة اللمسية الخفيفة والمتوسطة مع حماية من أخطاء المنصات غير الداعمة.
3. **`test/widget/presentation/micro_interactions_test.dart`:**
   - 5 اختبارات واجهة شاملة للتفاعلات الدقيقة، السحب للحذف، التراجع، وثبات التدوير.

---

## الملفات المعدلة
1. **`lib/features/subscriptions/presentation/widgets/subscription_card.dart`:**
   - تحويل المكون إلى `StatefulWidget` لدعم حركة النقر المصغرة (`AnimatedScale` بزمن 150ms $\le 300$ms).
   - دمج `Dismissible` مع خلفية حمراء وأيقونة سلة مهملات وكلمة «حذف» واهتزاز لمسي عند السحب.
2. **`lib/features/subscriptions/presentation/screens/home_screen.dart`:**
   - ربط السحب للحذف بإظهار شريط التراجع الفوري `Undo SnackBar` واستعادة السجل فورياً لموضعه بدقة وتحديث لوحة الملخص.
   - إضافة التغذية الراجعة اللمسية على الأزرار والإجراءات.
3. **`lib/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart`:**
   - دمج حماية النقر المزدوج `DebounceGuard` على زر الحفظ.
   - إعادة توزيع النموذج في الشاشات العريضة والوضع الأفقي (Landscape) إلى عمودين متوازنين بواسطة `LayoutBuilder`.
   - إضافة التغذية الراجعة اللمسية عند اختيار الدوريات، التواريخ، والفئات.
4. **`AI_Log.md`:**
   - إضافة السجل رقم 21 لتوثيق إنجاز المهمة `C-17`.
