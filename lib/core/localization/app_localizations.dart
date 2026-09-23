import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// عنوان التطبيق الرئيسي
  ///
  /// In ar, this message translates to:
  /// **'متتبع الدفعات الدورية'**
  String get appTitle;

  /// تبويب قائمة الاشتراكات
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get subscriptionsTab;

  /// تبويب لوحة الملخص والتحليلات
  ///
  /// In ar, this message translates to:
  /// **'الملخص'**
  String get summaryTab;

  /// تبويب الإعدادات العامة
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTab;

  /// حالة الاشتراك النشط
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// حالة الاشتراك المسدد
  ///
  /// In ar, this message translates to:
  /// **'مسدّد'**
  String get paid;

  /// حالة اقتراب موعد الاستحقاق
  ///
  /// In ar, this message translates to:
  /// **'مستحق قريباً'**
  String get dueSoon;

  /// حالة فوات موعد الاستحقاق
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get overdue;

  /// حالة التجربة المجانية
  ///
  /// In ar, this message translates to:
  /// **'تجربة مجانية'**
  String get trial;

  /// حالة الاشتراك الملغى
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get cancelled;

  /// حالة الاشتراك المؤرشف
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get archived;

  /// دورية الفوترة الشهرية
  ///
  /// In ar, this message translates to:
  /// **'شهرياً'**
  String get monthly;

  /// دورية الفوترة السنوية
  ///
  /// In ar, this message translates to:
  /// **'سنوياً'**
  String get yearly;

  /// دورية الفوترة الأسبوعية
  ///
  /// In ar, this message translates to:
  /// **'أسبوعياً'**
  String get weekly;

  /// دورية الفوترة اليومية
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get daily;

  /// دورية فوترة مخصصة بعدد أيام
  ///
  /// In ar, this message translates to:
  /// **'دورية مخصصة'**
  String get customCycle;

  /// عنوان شاشة إضافة اشتراك جديد
  ///
  /// In ar, this message translates to:
  /// **'إضافة اشتراك جديد'**
  String get addSubscription;

  /// عنوان شاشة تعديل الاشتراك
  ///
  /// In ar, this message translates to:
  /// **'تعديل الاشتراك'**
  String get editSubscription;

  /// زر الحفظ
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// زر الإلغاء
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// زر الحذف
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// زر التعديل
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// زر الأرشفة
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get archive;

  /// زر الاستعادة
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restore;

  /// زر تعليم كمسدد
  ///
  /// In ar, this message translates to:
  /// **'تسديد'**
  String get markAsPaid;

  /// زر تجديد الاشتراك
  ///
  /// In ar, this message translates to:
  /// **'تجديد'**
  String get renew;

  /// زر الإغلاق
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// زر التأكيد
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// حقل اسم الاشتراك
  ///
  /// In ar, this message translates to:
  /// **'اسم الاشتراك'**
  String get subscriptionName;

  /// حقل المبلغ أو القيمة
  ///
  /// In ar, this message translates to:
  /// **'المبلغ / القيمة'**
  String get subscriptionPrice;

  /// حقل العملة
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currency;

  /// حقل دورية الفوترة
  ///
  /// In ar, this message translates to:
  /// **'دورية الفوترة'**
  String get billingCycle;

  /// حقل تاريخ البدء
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء'**
  String get startDate;

  /// حقل تاريخ الاستحقاق القادم
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق القادم'**
  String get nextDueDate;

  /// حقل فئة الاشتراك
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// اسم الفئة الافتراضية
  ///
  /// In ar, this message translates to:
  /// **'غير مصنف'**
  String get uncategorized;

  /// حقل الملاحظات الاختياري
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات (اختياري)'**
  String get notes;

  /// حقل وصف وسيلة الدفع
  ///
  /// In ar, this message translates to:
  /// **'وسيلة الدفع (اختياري)'**
  String get paymentMethod;

  /// حقل عدد أيام الدورية المخصصة
  ///
  /// In ar, this message translates to:
  /// **'عدد الأيام للدورية المخصصة'**
  String get customDaysInterval;

  /// رسالة خطأ عند ترك الاسم فارغاً
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم الاشتراك'**
  String get nameRequired;

  /// رسالة خطأ عند تجاوز الحد الأقصى للاسم
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يتجاوز الاسم 60 حرفاً'**
  String get nameTooLong;

  /// رسالة خطأ عند إدخال مبلغ غير موجب
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون المبلغ أكبر من صفر'**
  String get pricePositive;

  /// عنوان الحالة الفارغة لقائمة الاشتراكات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اشتراكات مضافة بعد'**
  String get emptySubscriptionsTitle;

  /// شرح الحالة الفارغة لقائمة الاشتراكات
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة أول التزام دوري لتتبع نفقاتك ومواعيد تجديدك.'**
  String get emptySubscriptionsSubtitle;

  /// زر الإجراء الرئيسي في الحالة الفارغة
  ///
  /// In ar, this message translates to:
  /// **'إضافة أول اشتراك'**
  String get addFirstSubscription;

  /// رسالة الخطأ عند فشل جلب الاشتراكات
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل قائمة الاشتراكات'**
  String get errorLoadingSubscriptions;

  /// عنوان الحالة الفارغة للوحة الملخص
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية للتحليل'**
  String get emptySummaryTitle;

  /// شرح الحالة الفارغة للوحة الملخص
  ///
  /// In ar, this message translates to:
  /// **'أضف اشتراكاتك لعرض التحليلات والمكافئ الشهري والسنوي وتوزيع الفئات.'**
  String get emptySummarySubtitle;

  /// رسالة الخطأ في لوحة الملخص
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل ملخص التحليلات المالية'**
  String get errorLoadingSummary;

  /// بطاقة المكافئ الشهري
  ///
  /// In ar, this message translates to:
  /// **'المكافئ الشهري'**
  String get monthlyEquivalent;

  /// بطاقة المكافئ السنوي
  ///
  /// In ar, this message translates to:
  /// **'المكافئ السنوي'**
  String get annualEquivalent;

  /// عدد الاشتراكات النشطة
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات النشطة'**
  String get activeSubscriptionsCount;

  /// عنوان الاشتراك الأعلى كلفة
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك الأعلى كلفة'**
  String get highestCostSubscription;

  /// حالة عدم وجود اشتراك أعلى كلفة
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اشتراك نشط'**
  String get noHighestCost;

  /// عنوان توزيع الإنفاق
  ///
  /// In ar, this message translates to:
  /// **'توزيع الإنفاق حسب الفئات'**
  String get categoryDistribution;

  /// عنوان الاستحقاقات القادمة
  ///
  /// In ar, this message translates to:
  /// **'الاستحقاقات القادمة'**
  String get upcomingRenewals;

  /// حالة عدم وجود استحقاقات قادمة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد استحقاقات قادمة هذا الشهر'**
  String get noUpcomingRenewals;

  /// عنوان شاشة الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات العامة'**
  String get settingsTitle;

  /// قسم المظهر والسمة
  ///
  /// In ar, this message translates to:
  /// **'المظهر والسمة'**
  String get appearance;

  /// خيار السمة حسب النظام
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب النظام)'**
  String get themeSystem;

  /// خيار السمة الفاتحة
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// خيار السمة الداكنة
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// قسم العملة الافتراضية
  ///
  /// In ar, this message translates to:
  /// **'العملة الافتراضية'**
  String get defaultCurrency;

  /// قسم إدارة البيانات
  ///
  /// In ar, this message translates to:
  /// **'إدارة البيانات والنسخ الاحتياطي'**
  String get dataManagement;

  /// خيار تصدير النسخة الاحتياطية
  ///
  /// In ar, this message translates to:
  /// **'تصدير نسخة احتياطية'**
  String get exportBackup;

  /// خيار استيراد النسخة الاحتياطية
  ///
  /// In ar, this message translates to:
  /// **'استيراد نسخة احتياطية'**
  String get importBackup;

  /// خيار مسح كافة البيانات
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع البيانات نهائياً'**
  String get wipeData;

  /// عنوان حوار مسح البيانات
  ///
  /// In ar, this message translates to:
  /// **'تأكيد مسح البيانات نهائياً'**
  String get wipeDataConfirmTitle;

  /// نص التوجيه لكتابة كلمة التأكيد
  ///
  /// In ar, this message translates to:
  /// **'اكتب كلمة «مسح» لتأكيد الحذف النهائي وغير القابل للتراجع لكافة بيانات التطبيق:'**
  String get wipeDataConfirmPrompt;

  /// الكلمة الدقيقة المطلوبة لمسح البيانات
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get wipeDataKeyword;

  /// إشعار نجاح مسح البيانات
  ///
  /// In ar, this message translates to:
  /// **'تم مسح جميع البيانات بنجاح'**
  String get wipeDataSuccess;

  /// إشعار نجاح تصدير النسخة الاحتياطية
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير النسخة الاحتياطية بنجاح'**
  String get backupExportSuccess;

  /// إشعار نجاح استيراد النسخة الاحتياطية
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد النسخة الاحتياطية بنجاح'**
  String get backupImportSuccess;

  /// نص إصدار التطبيق
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق: 1.0.0'**
  String get appVersionInfo;

  /// نص إصدار مخطط قاعدة البيانات
  ///
  /// In ar, this message translates to:
  /// **'إصدار قاعدة البيانات: V2'**
  String get schemaVersionInfo;

  /// العد التنازلي للأيام المتبقية
  ///
  /// In ar, this message translates to:
  /// **'باقٍ {days} يوم'**
  String daysRemaining(int days);

  /// عدد الأيام المتأخرة
  ///
  /// In ar, this message translates to:
  /// **'متأخر {days} يوم'**
  String daysOverdue(int days);

  /// الاستحقاق في اليوم الحالي
  ///
  /// In ar, this message translates to:
  /// **'يستحق اليوم'**
  String get dueToday;

  /// عنوان حوار التغييرات غير المحفوظة
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get unsavedChangesTitle;

  /// رسالة حوار التغييرات غير المحفوظة
  ///
  /// In ar, this message translates to:
  /// **'لديك تعديلات غير محفوظة. هل أنت متأكد من رغبتك في المغادرة وتجاهل التغييرات؟'**
  String get unsavedChangesMessage;

  /// زر تجاهل التغييرات
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات'**
  String get discardChanges;

  /// زر متابعة التعديل
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعديل'**
  String get keepEditing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
