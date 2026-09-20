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
}
