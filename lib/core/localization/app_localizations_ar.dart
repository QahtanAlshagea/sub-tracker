// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع الاشتراكات';

  @override
  String get subscriptionsTab => 'الاشتراكات';

  @override
  String get summaryTab => 'الملخص';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get active => 'نشط';

  @override
  String get paid => 'مسدّد';

  @override
  String get dueSoon => 'مستحق قريباً';

  @override
  String get overdue => 'متأخر';

  @override
  String get trial => 'تجربة مجانية';

  @override
  String get cancelled => 'ملغى';

  @override
  String get archived => 'مؤرشف';

  @override
  String get monthly => 'شهرياً';

  @override
  String get yearly => 'سنوياً';

  @override
  String get weekly => 'أسبوعياً';

  @override
  String get daily => 'يومياً';

  @override
  String get customCycle => 'دورية مخصصة';

  @override
  String get addSubscription => 'إضافة اشتراك جديد';

  @override
  String get editSubscription => 'تعديل الاشتراك';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get archive => 'أرشفة';

  @override
  String get restore => 'استعادة';

  @override
  String get markAsPaid => 'تسديد';

  @override
  String get renew => 'تجديد';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get subscriptionName => 'اسم الاشتراك';

  @override
  String get subscriptionPrice => 'المبلغ / القيمة';

  @override
  String get currency => 'العملة';

  @override
  String get billingCycle => 'دورية الفوترة';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get nextDueDate => 'تاريخ الاستحقاق القادم';

  @override
  String get category => 'الفئة';

  @override
  String get uncategorized => 'غير مصنف';

  @override
  String get notes => 'ملاحظات (اختياري)';

  @override
  String get paymentMethod => 'وسيلة الدفع (اختياري)';

  @override
  String get customDaysInterval => 'عدد الأيام للدورية المخصصة';

  @override
  String get nameRequired => 'يرجى إدخال اسم الاشتراك';

  @override
  String get nameTooLong => 'لا يمكن أن يتجاوز الاسم 60 حرفاً';

  @override
  String get pricePositive => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String get emptySubscriptionsTitle => 'لا توجد اشتراكات مضافة بعد';

  @override
  String get emptySubscriptionsSubtitle =>
      'ابدأ بإضافة أول التزام دوري لتتبع نفقاتك ومواعيد تجديدك.';

  @override
  String get addFirstSubscription => 'إضافة أول اشتراك';

  @override
  String get errorLoadingSubscriptions => 'تعذر تحميل قائمة الاشتراكات';

  @override
  String get emptySummaryTitle => 'لا توجد بيانات كافية للتحليل';

  @override
  String get emptySummarySubtitle =>
      'أضف اشتراكاتك لعرض التحليلات والمكافئ الشهري والسنوي وتوزيع الفئات.';

  @override
  String get errorLoadingSummary => 'تعذر تحميل ملخص التحليلات المالية';

  @override
  String get monthlyEquivalent => 'المكافئ الشهري';

  @override
  String get annualEquivalent => 'المكافئ السنوي';

  @override
  String get activeSubscriptionsCount => 'الاشتراكات النشطة';

  @override
  String get highestCostSubscription => 'الاشتراك الأعلى كلفة';

  @override
  String get noHighestCost => 'لا يوجد اشتراك نشط';

  @override
  String get categoryDistribution => 'توزيع الإنفاق حسب الفئات';

  @override
  String get upcomingRenewals => 'الاستحقاقات القادمة';

  @override
  String get noUpcomingRenewals => 'لا توجد استحقاقات قادمة هذا الشهر';

  @override
  String get settingsTitle => 'الإعدادات العامة';

  @override
  String get appearance => 'المظهر والسمة';

  @override
  String get themeSystem => 'تلقائي (حسب النظام)';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get defaultCurrency => 'العملة الافتراضية';

  @override
  String get dataManagement => 'إدارة البيانات والنسخ الاحتياطي';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية';

  @override
  String get importBackup => 'استيراد نسخة احتياطية';

  @override
  String get wipeData => 'مسح جميع البيانات نهائياً';

  @override
  String get wipeDataConfirmTitle => 'تأكيد مسح البيانات نهائياً';

  @override
  String get wipeDataConfirmPrompt =>
      'اكتب كلمة «مسح» لتأكيد الحذف النهائي وغير القابل للتراجع لكافة بيانات التطبيق:';

  @override
  String get wipeDataKeyword => 'مسح';

  @override
  String get wipeDataSuccess => 'تم مسح جميع البيانات بنجاح';

  @override
  String get backupExportSuccess => 'تم تصدير النسخة الاحتياطية بنجاح';

  @override
  String get backupImportSuccess => 'تم استيراد النسخة الاحتياطية بنجاح';

  @override
  String get appVersionInfo => 'إصدار التطبيق: 1.0.0';

  @override
  String get schemaVersionInfo => 'إصدار قاعدة البيانات: V2';

  @override
  String daysRemaining(int days) {
    return 'باقٍ $days يوم';
  }

  @override
  String daysOverdue(int days) {
    return 'متأخر $days يوم';
  }

  @override
  String get dueToday => 'يستحق اليوم';

  @override
  String get unsavedChangesTitle => 'تغييرات غير محفوظة';

  @override
  String get unsavedChangesMessage =>
      'لديك تعديلات غير محفوظة. هل أنت متأكد من رغبتك في المغادرة وتجاهل التغييرات؟';

  @override
  String get discardChanges => 'تجاهل التغييرات';

  @override
  String get keepEditing => 'متابعة التعديل';
}
