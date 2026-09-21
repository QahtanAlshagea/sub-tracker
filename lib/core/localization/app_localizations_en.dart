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
  String get subscriptionsTab => 'Subscriptions';

  @override
  String get summaryTab => 'Summary';

  @override
  String get settingsTab => 'Settings';

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

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get renew => 'Renew';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get subscriptionName => 'Subscription Name';

  @override
  String get subscriptionPrice => 'Price / Amount';

  @override
  String get currency => 'Currency';

  @override
  String get billingCycle => 'Billing Cycle';

  @override
  String get startDate => 'Start Date';

  @override
  String get nextDueDate => 'Next Due Date';

  @override
  String get category => 'Category';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get notes => 'Notes (Optional)';

  @override
  String get paymentMethod => 'Payment Method (Optional)';

  @override
  String get customDaysInterval => 'Days interval for custom cycle';

  @override
  String get nameRequired => 'Please enter subscription name';

  @override
  String get nameTooLong => 'Subscription name cannot exceed 60 characters';

  @override
  String get pricePositive => 'Amount must be greater than zero';

  @override
  String get emptySubscriptionsTitle => 'No subscriptions yet';

  @override
  String get emptySubscriptionsSubtitle =>
      'Start by adding your first subscription to track expenses and renewal dates.';

  @override
  String get addFirstSubscription => 'Add First Subscription';

  @override
  String get errorLoadingSubscriptions => 'Failed to load subscriptions';

  @override
  String get emptySummaryTitle => 'Not enough data for analytics';

  @override
  String get emptySummarySubtitle =>
      'Add subscriptions to see financial metrics, monthly equivalents, and projections.';

  @override
  String get errorLoadingSummary => 'Failed to load financial summary';

  @override
  String get monthlyEquivalent => 'Monthly Equivalent';

  @override
  String get annualEquivalent => 'Annual Equivalent';

  @override
  String get activeSubscriptionsCount => 'Active Subscriptions';

  @override
  String get highestCostSubscription => 'Highest Expense';

  @override
  String get noHighestCost => 'No active subscription';

  @override
  String get categoryDistribution => 'Spending by Category';

  @override
  String get upcomingRenewals => 'Upcoming Renewals';

  @override
  String get noUpcomingRenewals => 'No renewals due this month';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance & Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get dataManagement => 'Data Management & Backups';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get wipeData => 'Wipe All Data Permanently';

  @override
  String get wipeDataConfirmTitle => 'Permanently Wipe All Data';

  @override
  String get wipeDataConfirmPrompt =>
      'Type «DELETE» to permanently wipe all application data:';

  @override
  String get wipeDataKeyword => 'DELETE';

  @override
  String get wipeDataSuccess => 'All data wiped successfully';

  @override
  String get backupExportSuccess => 'Backup exported successfully';

  @override
  String get backupImportSuccess => 'Backup imported successfully';

  @override
  String get appVersionInfo => 'App Version: 1.0.0';

  @override
  String get schemaVersionInfo => 'Database Schema: V2';

  @override
  String daysRemaining(int days) {
    return '$days days left';
  }

  @override
  String daysOverdue(int days) {
    return '$days days overdue';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get keepEditing => 'Keep Editing';
}
