// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sub Tracker';

  @override
  String get active => 'Active';

  @override
  String get paid => 'Paid';

  @override
  String get dueSoon => 'Due Soon';

  @override
  String get overdue => 'Overdue';

  @override
  String get trial => 'Free Trial';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get archived => 'Archived';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get weekly => 'Weekly';

  @override
  String get daily => 'Daily';

  @override
  String get customCycle => 'Custom Cycle';
}
