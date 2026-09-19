# 09 - المشاكل والملاحظات (Issues and Notes)

## 1. المشاكل التي واجهتنا أثناء التنفيذ وكيف عولجت

1. **طريقة فحص `MaterialTapTargetSize` في اختبار السمة:**
   - *المشكلة:* محاولة استدعاء `.resolve({})` على خاصية `tapTargetSize` داخل `ButtonStyle`.
   - *السبب:* `tapTargetSize` في Flutter هو قيمة مباشرة من تعداد `MaterialTapTargetSize?` وليس `WidgetStateProperty`.
   - *المعالجة:* تم تعديل الفحص إلى `expect(elevatedBtnStyle?.tapTargetSize, equals(MaterialTapTargetSize.padded))` بنجاح.

2. **نوع الإرجاع لدالة `copyWith` في `AppThemeExtension`:**
   - *المشكلة:* توقيع الدالة الأصلي كان يعيد `ThemeExtension<AppThemeExtension>` بدلاً من الصنف المشتق نفسه.
   - *المعالجة:* تم تخصيص نوع الإرجاع ليصبح `AppThemeExtension` مما يتيح الوصول المباشر للخصائص دون الحاجة لـ type cast.

3. **تحذير الاستيراد غير الضروري في التحليل الساكن:**
   - *المشكلة:* ظهور تحذير `unnecessary_import` لاستيراد `dart:ui` داخل ملف اختبار الرموز.
   - *المعالجة:* تم حذف سطر الاستيراد لأن عناصر `dart:ui` متوفرة تلقائياً عبر `flutter/material.dart`، مما حقق صفراً مطلقاً في تحذيرات التحليل الساكن.

---

## 2. ملاحظات للمهام القادمة (خارج نطاق هذه المهمة)

1. **الالتزام بالرموز في الشاشات القادمة (C-16):**
   - عند الشروع في بناء الشاشات الرئيسية (Home, Details, Add/Edit, Settings)، يجب استيراد `AppTokens` أو استخدام سمات `Theme.of(context)` حصراً، وتجنب أي قيم أبعاد أو ألوان عشوائية ثابتة.
2. **عناصر التحكم المخصصة (Custom Widgets):**
   - أي أيقونة أو زر مخصص يجب تغليفه بـ `InkWell` أو استخدام `constraints: BoxConstraints(minWidth: 48, minHeight: 48)` لضمان بقاء مساحات اللمس متوافقة مع معيار الوصولية WCAG AA.
